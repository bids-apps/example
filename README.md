## An example BIDS App
Every BIDS App needs to follow a minimal set of command arguments common across
all of the Apps. This allows users and developers to easily use and integrate
BIDS Apps with their environment.

This is an minimalistic example BIDS App consisting of a Dockerfile and simple
entrypoint script (written in this case in Python) accepting the standard BIDS
Apps command line arguments.

This App has the following comman line arguments:

    usage: run.py [-h]
                  [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...] |
                  --first_level_results FIRST_LEVEL_RESULTS]
                  bids_dir output_dir

    Example BIDS App entrypoint script.

    positional arguments:
      bids_dir              The directory with the input dataset formatted
                            according to the BIDS standard.
      output_dir            The directory where the output files should be stored.

    optional arguments:
      -h, --help            show this help message and exit
      --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]
                            (optional - first level only) label of the participant
                            that should be analyzed. The label corresponds to
                            sub-<participant_label> from the BIDS spec (so it does
                            not include "sub-"). If this parameter is not provided
                            all subjects should be analyzed. Multiple participants
                            can be specified with a space separated list.
      --first_level_results FIRST_LEVEL_RESULTS
                            (group level only) directory with outputs from a set
                            of participants which will be used as input to the
                            group level (this is where first level pipelines store
                            outputs via output_dir).

To run it in first level mode (for one participant):

    docker run -i --rm -v /Users/filo/data/ds005:/bids_dataset -v /Users/filo/first_level_results:/first_level_results bids/example /bids_dataset /first_level_results --participant_label 01

After doing this for all subjects (potentially in parallel) the group level analysis
can be run:

    docker run -i --rm -v /Users/filo/data/ds005:/bids_dataset -v /Users/filo/first_level_results:/first_level_results -v /Users/filo/group_level_results:/group_level_results bids/example /bids_dataset /group_level_results --first_level_results /first_level_results

For more information about the specification of BIDS Apps see [here](https://docs.google.com/document/d/1E1Wi5ONvOVVnGhj21S1bmJJ4kyHFT7tkxnV3C23sjIE/edit#).
