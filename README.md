phylanx-apex-retroactive-build
==============================
Builds a docker container from scratch to collect phylanx performance data from a specific point in history

(Work in progress)

### Usage
(todo: add a timestamp argument to control which version is downloaded; may need to manually set versions for apt/tar/pip libraries?)
```bash
git clone https://github.com/alex-r-bigelow/phylanx-apex-retroactive-build.git
docker build -t <docker name> .
```
