#python 3.7.3
#encoding=utf-8
#在 FontForge 中选择File,Execute Script...右键导入该脚本执行

#脚本参考：http://dmtr.org/ff.php

a=0 #起始字符位置
b=499 #结束字符位置

cx=20 #每行字符数量

import fontforge

font=fontforge.activeFont()
for i in range(a,b+1):
    glyph=font.createMappedChar(i)
    font.selection.select(glyph.originalgid)
    #导入
    y=int((glyph.originalgid-a)/cx)
    x=glyph.originalgid-a-y*cx
    img='Acy-Adobe-GB1-Regular-%d-%d_%02d_%02d.png'%(a,b,y,x)
    try:
        glyph.importOutlines(img)
        #提取字形
        font.autoTrace()
        #去除重叠（我发现FontForge在提取字形时有可能会生成重复的轮廓造成导出的字体显示不正常，所以需要这一步）
        font.removeOverlap()
        #删除背景图像
        #因 FontForge 未提供删除图像接口所以需要执行完后手动删除
    except FileNotFoundError:
        fontforge.logWarning(img+' 未找到，跳过')

#选择字形
font.selection.select(("ranges",None),a,b)
#之后需要手动选择Edit, Clear Background
