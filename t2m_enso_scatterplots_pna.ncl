


begin


  fout=addfile("/disk1/fhd/winter_forecast/data/t2m_cormean_pna.nc", "r")  ; -1
  cor=fout->var_name
  cor=dim_standardize(cor,0)
  fout1=addfile("/disk1/fhd/winter_forecast/data/emi_nino34_djf_prd.nc", "r")  ; -1
  enso_djf=fout1->nino34
  enso_djf=abs(enso_djf)
  year=ispan(1981,2016,1)
  
  pos=(/1,7,10,16,17,26,29,34/)      ; high    according 8 high & 8 low 
  neg=(/8,9,11,12,20,22,31,32/)      ; low

  color=new(36,"string")
  color(:)="black"
  color(1)="red"
  color(7)="red"
  color(10)="red"
  color(16)="red"
  color(17)="red"
  color(26)="red"
  color(29)="red"
  color(34)="red"

  
  
  color(8)="blue"
  color(9)="blue"
  color(11)="blue"
  color(12)="blue"
  color(20)="blue"
  color(22)="blue"
  color(31)="blue"
  color(32)="blue"
  pc=new(36,"float")
  pc=0
  
  tem_cor=escorc_n(enso_djf,cor,0,0)
  print(tem_cor)

;====================================================


  wks = gsn_open_wks ("eps","/disk1/fhd/winter_forecast/result/fig7d")    ; send graphics to PNG file
  plota=new(36,graphic) 
  res                      = True 

  res@gsnMaximize          = True    ; Maximize plot in window.

  res@gsnDraw              = False   ; Don't draw plot
  res@gsnFrame             = False   ; Don't advance frame

;  res@gsnPaperOrientation  = "portrait"

  res@gsnYRefLine           = 1            ; reference line
  res@gsnYRefLineDashPatterns = 0

  res@gsnXRefLine           = 0             ; reference line
  res@gsnXRefLineDashPattern = 0
;  res@xyMonoDashPattern    =False
;  res@xyMarkLineMode       = "Markers"  
;  res@xyMonoMarker         = True
;  res@xyMarkers            = 16
;  res@xyMarkers            = (/16, 10,1,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16/)          ; filled dot
;  res@xyMarkerSizeF        = 0.0135
;  res@xyMarkerColors       =cc

  res@tiMainString         = " "
  res@gsnLeftString  = "(d) Scatterplot (R=0.52)"
  res@gsnRightString  = ""
  res@gsnLeftStringFontHeightF = 0.034
  res@gsnRightStringFontHeightF = 0.028

  res@tiYAxisString        = "ENSO Amplitutde"
  res@tiXAxisString        = "Patern correlation"
  
  res@trYMaxF        =2.5
  res@trYMinF        =0
  
  res@trXMaxF        =2.5
  res@trXMinF        =-2.5
  res@vpHeightF = 0.4        ; Changes the aspect ratio
  res@vpWidthF  = 0.6
  res@tmYLLabelFontHeightF      =0.03  ;
  res@tmXBLabelFontHeightF      = 0.03
  res@tiYAxisFontHeightF  = 0.03

  
  res@tmXTOn    =False
  res@tmYROn    =False
  
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
  gsres@gsMarkerThicknessF= 15

;  res@tmYLBorderOn  =False
;  res@tmXBStyle ="Log"
  plot = gsn_csm_xy (wks,pc,pc,res)
  
 do i=0,35 
  gsres@gsMarkerColor       =color(i)
  plota(i)=gsn_add_polymarker(wks,plot,cor(i),enso_djf(i),gsres) 
  
  
end do  
 
;  plot = gsn_csm_xy (wks,pna,olr,res)    ; Create plot, but don't draw it yet

; Attach some text strings next to the markers.
  txres               = True
  txres@txFontHeightF = 0.0275
  txres@txJust        = "TopLeft"

; labels            = "  " + ispan(0,34,1)
;  labels(34) 	    = ""   ; Don't do the last one.

;  txid = gsn_add_text(wks,plot,labels,pna,olr,txres)

  draw(plot)    ; Drawing the plot will also cause text strings to appear
  frame(wks)    ; Advance the frame.
end 
