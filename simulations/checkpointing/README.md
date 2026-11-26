# GYSELA I/O Mini App

A minimal application demonstrating GYSELA I/O operations and testing the cpu performance scaling for 5D particle distribution functions.

## Overview

This mini application:

- Initialises a 5D particle distribution function (species × toroidal coordinates × velocity space)
- Writes the distribution function and mesh coordinates to HDF5 files
- Computes fluid moments (density, mean velocity, temperature) via C++ integration or in-situ Python computation
- Measures and saves CPU timing statistics

### Installation

Install Spack, then create the environment providing all the dependencies
(MPI, PDI, DDC, Dask, Deisa...) from the repository root:

```bash
spack env create gysela-io spack.yaml
spack env activate gysela-io && spack install
```

Build the mini-app from the activated environment:

```bash
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=gyselalibxx/toolchains/cpu.spack.gyselalibxx_env/toolchain.cmake
cmake --build build -j 4 -t gys_checkpointing
```

## Usage

### Basic run

```bash
./simulations/checkpointing/deisa-dask_launch_script.sh <nsimu_procs> <nworker_proc> [pdi_config.yml] [analytics_script.py]
```

- `nsimu_procs`: number of MPI ranks for the simulation
- `nworker_proc`: number of Dask workers to use for the analytics
- `pdi_config.yml`: PDI configuration file (default: uses `pdi_deisa.yaml`, in `simulations/checkpointing/params/`)
- `analytics_script.py`: the analytics script to launch from `processing/` (either `analytics.py` if you chose `pdi_deisa.yaml`, or `optimised_analytics.py` if you chose `optimised_pdi_deisa.yaml`)

The launch script activates the `gysela-io` Spack environment located in `~/spack`,
so both must have been created beforehand. Override the Spack location and
environment name with the `SPACK_DIR` and `SPACK_ENV_NAME` environment variables.

### Sequential Run

```bash
source simulations/checkpointing/activate_deisa_spack_env.sh
mpirun -n <nprocs> ./build/simulations/checkpointing/gys_checkpointing simulations/checkpointing/params/gys_checkpointing.yaml simulations/checkpointing/params/seq_pdi.yaml
```

### Run with OAR (Grid'5000)

```bash
./simulations/checkpointing/oar_deisa-dask_launch_script.sh <nsimu_procs> <nworker_proc>
```

## Configuration

Edit `simulations/checkpointing/params/gys_checkpointing.yaml` to configure:

- **Mesh**: Grid sizes and ranges for toroidal coordinates (Tor1, Tor2, Tor3) and velocity space (Vpar, Mu)
- **Species**: Number of species, charges, masses
- **Application version**: `"mpi_transpose"` or `"in-situ-diagnostic"` (the latter enables Python-based fluid moments computation)
- **Subfiling**: Switch subfiling on/off at runtime

## Output Files

- **`plasma1.h5`**: Checkpoint file with the distribution function (name configurable via `gysela_io_filename`)
- **`cpu_time.h5`**: CPU timing statistics (initialisation, transpose, GPU↔CPU transfer, I/O)
- **`fdistribu_5D_output.h5`**: Distribution function and mesh coordinates
- **`fluid_moments.h5`**: Fluid moments computed by C++ integration
- **`output/normal_fluid_moments_<iter>.h5`**: Fluid moments computed in-situ via Dask + Deisa
