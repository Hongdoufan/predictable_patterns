load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/disk1/fhd/function/tnflux2d_xy_qg.ncl"



;===========================================================
; Calculate quasi-geostrophic version T-N flux on a pressure
; level for one time point based on formula (38) of Takaya
; and Nakamura (2001).
;
;* Reference:
;   Takaya,K.,and H.Nakamura (2001), A Formulation of a
;   Phase-Independent Wave-Activity Flux for Stationary
;   and Migratory Quasigeostrophic Eddies on a Zonally
;   Varying Basic Flow, J. Atmos. Sci., 58, 608-627.
;
;* Input data:
;   ZB : Basic state for the geopotential height, usually
;        use the climatological mean for the period concerned.
;   ZA : Anomaly of the geopotential height
;   ZB and ZA should be in (lat,lon) format with metadata
;
;* Output data:
;   TNx   : X-component for the TN flux
;   TNy   : Y-component for the TN flux
;   DivTN : Divergence of the TN flux
;
;* Example:
;     temp = tnflux2d_xy_qg(hclim,hano)
;     tnx  = temp(0,:,:)
;     tny  = temp(1,:,:)
;     div  = temp(2,:,:)
;
;* History:
;   2013-03-11: First written by Dr. WANG Lin of IAP, CAS.
;   2013-04-05: Modified by Dr. WANG Lin, adding coordinate
;               metadata to the output.
;===========================================================
begin
fout=addfile("/disk1/fhd/winter_forecast/data/msn.t2m.pc2.reg.200z.nc", "r")
climate=addfile("/disk1/fhd/winter_forecast/data/hgt200_in11_6mon_wina.nc", "r")

ZB_prd=climate->cli
ZB_prd=ZB_prd*1./9.8
ZA=fout->hgt

copy_VarCoords(ZA, ZB_prd)
tn_4_x=new((/181,360/),"float")
tn_4_y=new((/181,360/),"float")

    temp =tnflux2d_xy_qg(ZB_prd,ZA)         
    tnx  = temp(0,:,:)
    tny  = temp(1,:,:)
    
tnx({0:15},:)=1e+20
tny({0:15},:)=1e+20

   
system("rm -f /disk1/fhd/winter_forecast/data/msn.t2m.pc2.200z.tn2d.nc")
fout=addfile("/disk1/fhd/winter_forecast/data/msn.t2m.pc2.200z.tn2d.nc", "c")
fout->tnx=tnx
fout->tny=tny
 

end

