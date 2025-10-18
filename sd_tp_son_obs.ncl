
begin
; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
 nyear=36
 ff=addfile ("/disk3/jra55/monthly/snow/snowd.mon.mean.nc", "r")
  TIME2   = ff->time
  YYYY2   = cd_calendar(TIME2,-2)/100                 
  season = "JFM" 

var2= ff->snowd(284:715,:,:) ;1981.09
lat=ff->lat
lon=ff->lon
;   obs=var2(0:nyear-1,:,:)
   obs1=month_to_season (var2, season)
   obs_cli1=dim_avg_n(obs1,0)
   SST1=new((/nyear,dimsizes(lat),dimsizes(lon)/),"float")
   do i=0,nyear-1
   SST1(i,:,:)=obs1(i,:,:)-obs_cli1
   end do   

   copy_VarCoords(obs1, SST1) 
   SST1 = dtrend_msg_n(SST1&time,SST1,True,False,0)


; ==============================================================
; User defined parameters that specify region of globe and
; ==============================================================
  latSd   =  24
  latNd   =  40
  lonLd   =  70
  lonRd   =  105
  sstd=SST1(0,{latSd:latNd},{lonLd:lonRd})
  ;===========================================================================
  
  rad   = 4.*atan(1.)/180.
  lat4   = sstd&lat
  clat4  = lat4
  clat4  = sqrt( cos(rad*lat4) ) 
  area_d=wgt_areaave(SST1(:,{latSd:latNd},{lonLd:lonRd}), clat4, 1.0, 0)*1000.
  aaa=dim_standardize_Wrap(area_d, 0)
  print(aaa)     ; 0.6450729


sd_ea_pc=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc","r")
sd_pc=sd_ea_pc->sic_index
cor=escorc(sd_pc, aaa)
print(cor)

f      = addfile("/disk1/fhd/winter_forecast/data/msn_eof_t2m.nc", "r")
eof_ts=f->eof_ts(0:3,:)
ts=escorc(eof_ts(3,:), aaa)
print(ts)
exit()
sdtp=new(37,"float")
sdtp(0:35)=sd_pc
sdtp(36)=area_d
aaa=dim_standardize_Wrap(sdtp, 0)
sds=dtrend(aaa,False)   ;-22.06571
;exit()
print(sds)
;  sic_index_=dim_standardize_Wrap(area_d,0)
;system("rm -f /disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc")
;fout=addfile("/disk1/fhd/winter_forecast/data/sd_tp_djf_son.nc", "c")
;fout->sic_index=sic_index


end
