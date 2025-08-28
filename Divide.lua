nx=20
ny=25

require("alien")

alien.user32.SetProcessDPIAware:types{ret="int",abi="stdcall"}
alien.user32.SetProcessDPIAware()

local strpath
local noclip=false
if arg[1]==nil then
	require("wx")
	strpath=wx.wxFileSelector("选择文件",".","","png","便携式网络图像文件|*.png|所有文件|*",wx.wxFD_OPEN+wx.wxFD_FILE_MUST_EXIST)
else
	strpath=arg[1]
end
if strpath==nil or strpath=='' then
	os.exit()
end

if arg[2]==nil then
	noclip=wx.wxMessageBox("是否需要裁切空白？","裁切",wx.wxYES_NO)==wx.wxNO
else
	noclip=arg[2]=='noclip'
end

local _,sppos=strpath:reverse():find('%.')
local dpn=strpath:sub(1,#strpath-sppos)

require("gd")

function clipToChar(imgTable,x,y,w,h,clipBlankPx)
	local clipX,clipY,clipW,clipH=x,y,w,h
	if not noclip then
		local blankColor=imgTable:colorAllocate(255,255,255)
		if clipBlankPx~=-1 then
			--Clip left border
			for ix=x,x+w-1,1 do
				local nbFound=false
				for iy=y,y+h-1,1 do
					if blankColor~=imgTable:getPixel(ix,iy) then
						nbFound=true
						break
					end
				end
				if nbFound then
					clipX=math.max(x,ix-clipBlankPx)
					break
				end
				if ix==x+w-1 then
					return 0,0,0,0
				end
			end
			--Clip top border
			for iy=y,y+h-1,1 do
				local nbFound=false
				for ix=x,x+w-1,1 do
					if blankColor~=imgTable:getPixel(ix,iy) then
						nbFound=true
						break
					end
				end
				if nbFound then
					clipY=math.max(y,iy-clipBlankPx)
					break
				end
			end
			--Clip right border
			for ix=x+w-1,x,-1 do
				local nbFound=false
				for iy=y,y+h-1,1 do
					if blankColor~=imgTable:getPixel(ix,iy) then
						nbFound=true
						break
					end
				end
				if nbFound then
					clipW=math.min(x+w-clipX,ix-clipX+clipBlankPx)
					break
				end
			end
			--Clip bottom border
			for iy=y+h-1,y,-1 do
				local nbFound=false
				for ix=x,x+w-1,1 do
					if blankColor~=imgTable:getPixel(ix,iy) then
						nbFound=true
						break
					end
				end
				if nbFound then
					clipH=math.min(y+h-clipY,iy-clipY+clipBlankPx)
					break
				end
			end
			--调整尺寸以符合原图比例w/h
			local ratio=w/h
			local clipRatio=clipW/clipH
			if clipRatio>ratio then--补充高度
				local newH=h*clipW/w
				clipY=clipY+(clipH-newH)/2
				clipH=newH
				--看补充后是否出界
				clipY=math.max(clipY,y)
				clipY=math.min(clipY,y+h-clipH)
			elseif clipRatio<ratio then--补充宽度
				local newW=w*clipH/h
				clipX=clipX+(clipW-newW)/2
				clipW=newW
				--看补充后是否出界
				clipX=math.max(clipX,x)
				clipX=math.min(clipX,x+w-clipW)
			end
		end
	end
	return clipX,clipY,clipW,clipH
end

img=gd.createFromPng(strpath)
local dw=img:sizeX()/nx
local dh=img:sizeY()/ny
local charImg=gd.createTrueColor(dw,dh)
for j=0,ny-1,1 do
	for i=0,nx-1,1 do
		local x,y,w,h=clipToChar(img,i*dw,j*dh,dw,dh,5)
		if w~=0 then
			charImg:copyResampled(img,0,0,x,y,dw,dh,w,h)
			charImg:png(string.format("%s_%02d_%02d.png",dpn,j,i))
		end
	end
end
