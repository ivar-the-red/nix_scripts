#!/usr/bin/python3

import argparse
import time
import math

def perform_operations(duration):
    start_time = time.time()
    while (time.time() - start_time) < duration:
        # Perform some repetitive mathematical operation
        result = 0
        for i in range(100000):
            result += math.sqrt(i)

def main():
    parser = argparse.ArgumentParser(description="Script to perform repetitive mathematical operations")
    parser.add_argument("-s", "--seconds", type=int, default=900, help="Number of seconds to run the script")
    args = parser.parse_args()

    perform_operations(args.seconds)

if __name__ == "__main__":
    main()

