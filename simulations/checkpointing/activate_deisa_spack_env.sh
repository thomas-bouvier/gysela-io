SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd $SCRIPT_DIR/../.. && pwd)"

# Spack installation and environment providing all the dependencies
# (MPI, PDI, DDC, Dask, Deisa...) used by the simulation and the analytics
SPACK_DIR="${SPACK_DIR:-${HOME}/spack}"
SPACK_ENV_NAME="${SPACK_ENV_NAME:-gysela-io}"

. ${SPACK_DIR}/share/spack/setup-env.sh
spack env activate ${SPACK_ENV_NAME}

# `spack env activate` may skip loading the runtime environment (PYTHONPATH) when
# it emits warnings, so the Python packages installed by Spack are not visible.
# Add them explicitly through the stable view path.
for site_packages in ${SPACK_DIR}/var/spack/environments/${SPACK_ENV_NAME}/.spack-env/view/lib/python*/site-packages; do
    [ -d "${site_packages}" ] && export PYTHONPATH=${site_packages}:${PYTHONPATH:-}
done

# Make the `processing` package (in-situ analytics) importable from the repo
export PYTHONPATH=${BASE_DIR}:${PYTHONPATH:-}
