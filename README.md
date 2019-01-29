phylanx-apex-retroactive-build
==============================
Collect phylanx performance data from a specific point in history

(Work in progress)

## Building
```bash
git clone https://github.com/alex-r-bigelow/phylanx-apex-retroactive-build.git
cd phylanx-apex-retroactive-build
bash generate_scripts "Jan 1, 2019" ~/install_dir
```
This will create `install_dir`, containing two scripts:
- `build.sh` will clone HPX and Phylanx and set up OTF2 to in your home directory (you can change this with `OTF2_DIR`, `HPX_REPO`, and `PHYLANX_REPO` environment variables), and then build both HPX and Phylanx in `install_dir`
- `run.sh` is a template that you can use for running based on that build
