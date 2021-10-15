# Discovery Scripts

Scripts for getting starting on Northeastern's high performance computing cluster

## About Discovery

* [Main site](https://rc.northeastern.edu/)
* [Documentation](https://rc-docs.northeastern.edu/en/latest/welcome/welcome.html)
* [Tutorial](https://www.linkedin.com/checkpoint/enterprise/login/74653650?pathWildcard=74653650&application=learning&redirect=https%3A%2F%2Fwww%2Elinkedin%2Ecom%2Flearning%2Fcontent%2F1139340%3Fu%3D74653650) (Requires NU ID.)


## Environment

Discovery uses [Slurm](https://slurm.schedmd.com/) to schedule jobs.
* [How to use Slurm on Discovery](https://rc-docs.northeastern.edu/en/latest/using-discovery/usingslurm.html)

A simple sbatch script from the introductory tutorial:

```bash

#!/bin/bash
#SBATCH --partition=express
#SBATCH --job-name=test
#SBATCH --time=00:05:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --output=%j.output
#SBATCH --error=%j.error

echo "HELLO WORLD!"

```

Packages that aren't available as a [module](https://linux.die.net/man/1/module) by default can be installed with [Spack](https://spack.io/) to your home directory.

* [Howe to use Spack on Discovery](https://rc-docs.northeastern.edu/en/latest/software/spack.html)
* [Packages available](https://spack.readthedocs.io/en/latest/package_list.html)

## Spark

Running Spark requires scheduling time on two different types of node (a Driver and one or more Workers). Spark 3 is also not currently available as a module. So running Spark 3 demontrates several features of the environment.


### Installing Dependencies

First install Spack according to the [documentation](https://rc-docs.northeastern.edu/en/latest/software/spack.html).

```bash

git clone https://github.com/spack/spack.git

# Schedule an environment that can handle a larger workload.
srun -p short --pty --export=ALL -N 1 -n 28 --exclusive /bin/bash

export SPACK_ROOT=/home/<yourusername>/spack

. $SPACK_ROOT/share/spack/setup-env.sh

```

Install Spark 3 with Hadoop and OpenJDK 11.

```bash

spack install spark@3.1.1 +hadoop ^hadoop@3.2.1
spack install openjdk@11.0.1

```

Upload or move the [sample sbatch script](spark/spark_with_slurm.sh) and [pi.py](spark/pi.py) to your home directory and run it:

```bash

sbatch spark_with_slurm.sh


```

You should see output from Slurm that the job has been scheduled with a job ID, and then <job ID>.error and <job ID>.output in your home directory. The .error file should have some logging from Spark that includes how long the job took to run. You can see a list of your jobs at [ood.discovery.neu.edu](https://ood.discovery.neu.edu/pun/sys/dashboard) (NU ID required).

Increase the number of nodes at the [top]() of the sbatch file:

```bash
.
.
.
#SBATCH --partition=express
#SBATCH --job-name=spark-cluster
#SBATCH --nodes=3
.
.
.

```

pi.py contains a perfectly parallel algorithm for estimating pi using a [Monte Carlo method](https://en.wikipedia.org/wiki/Monte_Carlo_method). *Running the job with more nodes should increase performance.*

If you find that a simple, parallelizable job is not scaling, it likely means you are running several Driver nodes instead of one Driver and several Workers. See [spark_with_slurm.sh](spark/spark_with_slurm.sh) for details.

