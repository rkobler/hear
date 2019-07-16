# high-variance electrode artifact removal (HEAR) algorithm

HEAR is a simple, yet efficient algorithm to remove transient, high-variance artifacts from multivariate time-series signals (e.g., electroencephalographic (EEG) signals).

### Reference:

Kobler, R. J., Sburlea, A. I., Mondini, V. & Müller-Putz, G. R. HEAR to remove pops and drifts: the high-variance electrode artifact removal (HEAR) algorithm. 
In Proceedings of the Annual International Conference of the IEEE Engineering in Medicine and Biology Society, EMBS, 2019 (accepted)

HEAR can be applied offline and online.
The repository contains a reference implementation in Matlab and a dataset of simulated EEG signals.
The demonstration dataset is stored in the [eeglab](https://sccn.ucsd.edu/eeglab/index.php) format.

## Getting Started
* Download [HEAR](https://github.com/rkobler/hear) and open the downloaded folder.
* Startup the [eeglab](https://sccn.ucsd.edu/wiki/Chapter_01:_Loading_Data_in_EEGLAB#Installing_EEGLAB_and_tutorial_files) toolbox:
* Open the `train_HEAR.m` script. The script loads a calibration dataset (`demo_simrest.set`) that contains simulated artifact-free EEG signals. Then HEAR is fit to the data. The parameter `is_causal` defines if HEAR should be used online `is_causal = true` or offline `is_causal = false`. The calibrated model is stored to the disk 'hear_mdl.mat'.
* The script `apply_HEAR.m` uses the calibrated model to correct pop and drift artifacts in a second dataset (`demo_simreach.set`).

## Contact
Feel free to contact me at [reinmar.kobler@tugraz.at](mailto:reinmar.kobler@tugraz.at).

## Acknowledgements
This work was supported by the European Research Council (ERC) under the European Union's Horizon 2020 research and innovation programme (Consolidator Grant 681231 'Feel Your Reach').
