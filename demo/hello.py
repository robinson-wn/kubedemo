import logging
from operator import add
from random import random
from time import time

import numpy as np
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("kubedemo").getOrCreate()
spark.sparkContext.setLogLevel("ERROR")
logging.getLogger('py4j.clientserver').setLevel(logging.WARNING)
# spark.conf.set("spark.sql.shuffle.partitions", "8")


print("Hello World from PySpark")

MILLION = 1000000
n = MILLION * 100
partitions = 20
# 7 = 15.6s, 1 = 34s

print(f"Computing Pi with {n:,} points using {partitions} partitions")

def is_point_inside_unit_circle(_):
    x, y = random(), random()
    return 1 if x * x + y * y < 1 else 0


def calculate_pi():
    t_0 = time()
    # parallelize creates a spark Resilient Distributed Dataset (RDD)
    # its values are useless in this case
    # but allows us to distribute our calculation (inside function)
    count = spark.sparkContext.parallelize(range(0, n), partitions) \
        .map(is_point_inside_unit_circle).reduce(add)
    print(np.round(time() - t_0, 3), "seconds elapsed for spark approach and n=", n)
    print("Pi is roughly %f" % (4.0 * count / n))


calculate_pi()
