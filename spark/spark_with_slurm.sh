#!/bin/bash
#SBATCH --partition=express
#SBATCH --job-name=spark-cluster
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=5
#SBATCH --mem=20G
#SBATCH --time=00:05:00
#SBATCH --output=%j.output
#SBATCH --error=%j.error

# Load Java 11, Python 3 and Spark modules.
# Depends on spack installations of Spark with Hadoop and OpenJDK 11.
module load $(spack module tcl find openjdk@11.0.1)
module load $(spack module tcl find spark@3.1.1)
module load python/3.6.6

# Variables
export SPARK_HOME=$(spack location -i spark@3.1.1)
export SPARK_LOG_DIR=${SPARK_LOG_DIR:-$HOME/.spark/logs}
export SPARK_WORKER_DIR=${SPARK_WORKER_DIR:-$HOME/.spark/worker}
export SPARK_LOCAL_DIRS=${SPARK_LOCAL_DIRS:-/tmp/spark}

# Transfer node resource information and ID from Slurm to Spark.
export SPARK_IDENT_STRING=$SLURM_JOBID
export SPARK_WORKER_CORES=${SLURM_CPUS_PER_TASK:-1}
export SPARK_MEM=$(( ${SLURM_MEM_PER_CPU:-4096} * ${SLURM_CPUS_PER_TASK:-1} ))M
export SPARK_DAEMON_MEMORY=$SPARK_MEM
export SPARK_WORKER_MEMORY=$SPARK_MEM
export SPARK_EXECUTOR_MEMORY=$SPARK_MEM

mkdir -p $SPARK_LOG_DIR $SPARK_WORKER_DIR

# Start driver node.
$SPARK_HOME/sbin/start-master.sh
sleep 1
SPARK_DRIVER_URL=$(grep -Po '(?=spark://).*' $SPARK_LOG_DIR/spark-${SPARK_IDENT_STRING}-org.*master*.out)

# Start the workers.
export SPARK_NO_DAEMONIZE=1
srun  --output=$SPARK_LOG_DIR/spark-%j-workers.out --label start-worker.sh ${SPARK_DRIVER_URL} &

# Submit job.
spark-submit --master ${SPARK_DRIVER_URL} --total-executor-cores $((SLURM_NTASKS * SLURM_CPUS_PER_TASK)) ~/pi.py 100

# Stop the driver and workers.
scancel ${SLURM_JOBID}.0
$SPARK_HOME/sbin/stop-master.sh
