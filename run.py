#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from glob import glob
from pathlib import Path

import nibabel
import numpy

__version__ = open(Path(__file__).parent / "version").read()


def run(command, env=None):
    if env is None:
        env = {}
    merged_env = os.environ
    merged_env.update(env)
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        shell=True,
        env=merged_env,
    )
    while True:
        line = process.stdout.readline()
        line = str(line, "utf-8")[:-1]
        print(line)
        if line == "" and process.poll() != None:
            break
    if process.returncode != 0:
        raise Exception("Non zero return code: %d" % process.returncode)


def return_parser():
    parser = argparse.ArgumentParser(
        description="Example BIDS App entrypoint script."
    )
    parser.add_argument(
        "bids_dir",
        help="The directory with the input dataset formatted according to the BIDS standard.",
    )
    parser.add_argument(
        "output_dir",
        help="""
The directory where the output files should be stored.
If you are running group level analysis this folder should be prepopulated
with the results of the participant level analysis.""",
    )
    parser.add_argument(
        "analysis_level",
        help="""
Level of the analysis that will be performed.
Multiple participant level analyses can be run independently
in parallel) using the same output_dir.""",
        choices=["participant", "group"],
    )
    parser.add_argument(
        "--participant_label",
        help="""
The label(s) of the participant(s) that should be analyzed.
The label corresponds to sub-<participant_label> from the BIDS spec
(so it does not include "sub-"). If this parameter is not provided all subjects should be analyzed.
Multiple participants can be specified with a space separated list.""",
        nargs="+",
    )
    parser.add_argument(
        "--skip_bids_validator",
        help="Whether or not to perform BIDS dataset validation.",
        action="store_true",
    )
    parser.add_argument(
        "-v",
        "--version",
        action="version",
        version=f"BIDS-App example version {__version__}",
    )
    return parser


def main(argv=sys.argv):

    parser = return_parser()
    args, unknowns = parser.parse_known_args(argv[1:])

    if unknowns:
        print(f"The following arguments are unknown: {unknowns}")
        exit(64)

    if not args.skip_bids_validator:
        run(f"bids-validator {args.bids_dir}")

    subjects_to_analyze = []
    # only for a subset of subjects
    if args.participant_label:
        subjects_to_analyze = args.participant_label
    # for all subjects
    else:
        subject_dirs = glob(os.path.join(args.bids_dir, "sub-*"))
        subjects_to_analyze = [
            subject_dir.split("-")[-1] for subject_dir in subject_dirs
        ]

    # running participant level
    if args.analysis_level == "participant":

        # find all T1s and skullstrip them
        for subject_label in subjects_to_analyze:
            for T1_file in glob(
                os.path.join(
                    args.bids_dir, f"sub-{subject_label}", "anat", "*_T1w.nii*"
                )
            ) + glob(
                os.path.join(
                    args.bids_dir,
                    f"sub-{subject_label}",
                    "ses-*",
                    "anat",
                    "*_T1w.nii*",
                )
            ):
                out_file = os.path.split(T1_file)[-1].replace(
                    "_T1w.", "_brain."
                )
                cmd = (
                    f"bet {T1_file} {os.path.join(args.output_dir, out_file)}"
                )
                print(cmd)
                run(cmd)

        exit(0)

    elif args.analysis_level == "group":
        brain_sizes = []
        for subject_label in subjects_to_analyze:
            for brain_file in glob(
                os.path.join(args.output_dir, f"sub-{subject_label}*.nii*")
            ):
                data = nibabel.load(brain_file).get_fdata()
                # calculate average mask size in voxels
                brain_sizes.append((data != 0).sum())

        with open(
            os.path.join(args.output_dir, "avg_brain_size.txt"), "w"
        ) as fp:
            fp.write(
                f"Average brain size is {numpy.array(brain_sizes).mean()} voxels"
            )
            print(
                f"Results were saved in {Path(args.output_dir) / 'avg_brain_size.txt'}"
            )

        exit(0)


if __name__ == "__main__":
    main()
