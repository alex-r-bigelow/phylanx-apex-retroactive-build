phylanx-apex-retroactive-build
==============================
Collect phylanx performance data from a specific point in history

(Work in progress)

## Building
```bash
git clone https://github.com/alex-r-bigelow/phylanx-apex-retroactive-build.git
cd phylanx-apex-retroactive-build
bash build.sh [OPTIONAL: date (e.g. "Jan 1, 2019"), defaults to now]
# (note that build.sh takes a while; running it in a screen is a good idea)
```
This will create:
- an `install` directory, containing `otf2` builds and `hpx` / `phylanx` repositories
- a `build-#########` directory
- a `build-#########.sh` file
in your home directory.

## Running
If all goes well, you should then be able to:
```bash
cd build-#########
bash run.sh
# (note that run.sh will take a LONG time; you should definitely run it in a screen)
```
Inside the `build-#########` directory, this will create several `run##` directories,
corresponding to how many threads were used for each run. Each of those directories
will contain OTF2 traces, as well as the console outputs of each run.

## When the build doesn't work
Chances are, you may need to fiddle with library versions; rather than having to
run `build.sh` again, you can just make changes to the generated `build-#########.sh`
file, and run it instead.

## Ew, leave my home directory alone!
If you want all of these files to wind up somewhere else:
```bash
export PARB_TARGET=/path/where/this/stuff/should/go
bash build.sh
```
