from PyGnuplot import gp

fig = gp()

fig.a('set pm3d map')
fig.a('set xrange[0:511]')
fig.a('set yrange[0:255]')
fig.a('set xlabel "u"')
fig.a('set ylabel "value"')
fig.a('set zlabel "nb"')

fig.a('rgb(r,g,b) = int(r)*65536 + int(g)*256 + int(b)')

fig.a('splot "build/bin/gnuplot.dat" u 1:2:(rgb($5, $4, $3)) with points pt 7 ps variable lc rgb variable', timeout=60)

