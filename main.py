import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
from Filters import irrFilter


SAMPLES = 1048576
TOP_VALUE = 32767
sounds = np.abs((np.random.rand(SAMPLES)+0.01)*TOP_VALUE)
x = np.linspace(0,SAMPLES*20,SAMPLES)


fig, ax = plt.subplots(2)
plt.subplots_adjust(bottom=0.25)

l, = ax[0].plot(x, sounds)
ax[0].axis([0, 100, 0, TOP_VALUE])

filtered = irrFilter(sounds)
ax[1].plot(x, filtered)
ax[1].axis([0, 100, 0, TOP_VALUE])

axcolor = 'lightgoldenrodyellow'
spos = Slider(plt.axes([0.2, 0.1, 0.6, 0.02], facecolor=axcolor), 'Pos', 1, SAMPLES/50)

def update(val):
    pos = spos.val
    ax[0].axis([pos,pos+100,0,TOP_VALUE])
    ax[1].axis([pos,pos+100,0,TOP_VALUE])
    fig.canvas.draw_idle()

spos.on_changed(update)

plt.show()