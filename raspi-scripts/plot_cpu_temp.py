#!/usr/bin/python3

from gpiozero import CPUTemperature
import matplotlib.pyplot as plt
import numpy as np
import time
import argparse
from datetime import datetime


def main():
    current_datetime = datetime.now()
    datetime_string = current_datetime.strftime('%Y%m%d_%H%M%S')
    plot_directory = '/home/ivar/cpu_plots/'
    plot_prefix = plot_directory + datetime_string

    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--samples', type=int, help='Number of samples to take')
    args = parser.parse_args()

    if args.samples is not None:
        num_samples = args.samples
    else:
        num_samples = 1000
    
    cpu = CPUTemperature()
    temperatures = []
    seconds = []

    for i in range(num_samples):
        temperatures.append(cpu.temperature)
        seconds.append(i)
        time.sleep(1)
    
    plt.ion()
    fig, ax = plt.subplots()
    line, = ax.plot(seconds, temperatures)
    ax.set_xlabel('Seconds')
    ax.set_ylabel('Temperature C')

    line.set_xdata(seconds)
    line.set_ydata(temperatures)
    ax.relim()
    ax.autoscale_view()
    fig.canvas.draw()
    fig.canvas.flush_events()
    plt.savefig(plot_prefix + '.png')

if __name__ == '__main__':
    main()
