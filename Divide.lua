nx=20
ny=25

require("alien")

alien.user32.SetProcessDPIAware:types{ret="int",abi="stdcall"}
alien.user32.SetProcessDPIAware()

local strpath
local noclip=false
if arg[1]==nil then
	require("wx")
	strpath=wx.wxFileSelector("ѡ���ļ�",".","","png","��Яʽ����ͼ���ļ�|*.png|�����ļ�|*",wx.wxFD_OPEN+wx.wxFD_FILE_MUST_EXIST)
else
	strpath=arg[1]
end
if strpath==nil or strpath=='' then
	os.exit()
end

if arg[2]==nil then
	noclip=wx.wxMessageBox("�Ƿ���Ҫ���пհף�","����",wx.wxYES_NO)==wx.wxNO
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
			--�����ߴ��Է���ԭͼ����w/h
			local ratio=w/h
			local clipRatio=clipW/clipH
			if clipRatio>ratio then--����߶�
				local newH=h*clipW/w
				clipY=clipY+(clipH-newH)/2
				clipH=newH
				--��������Ƿ����
				clipY=math.max(clipY,y)
				clipY=math.min(clipY,y+h-clipH)
			elseif clipRatio<ratio then--������
				local newW=w*clipH/h
				clipX=clipX+(clipW-newW)/2
				clipW=newW
				--��������Ƿ����
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
