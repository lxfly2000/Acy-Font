require("gd")

width=8000
height=10000

nx=20
ny=25

img=gd.createTrueColor(width,height)
white=img:colorAllocate(255,255,255)
gridColor=img:colorAllocate(200,91,252)
img:fill(0,0,white)

local ew=width/nx
local eh=height/ny

for x=0,width-1,ew do
	img:line(x,0,x,height-1,gridColor)
end

for y=0,height-1,eh do
	img:line(0,y,width-1,y,gridColor)
end

img:png("bg.png")
