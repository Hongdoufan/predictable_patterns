;---------------------------------------------
; regrid_1.ncl
;
; Concepts illustrated:
;   - Interpolating from one grid to another using bilinear interpolation
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Paneling two plots vertically on a page
;   - Adding a common labelbar to paneled plots
;   - Adding units attributes to lat/lon arrays
;   - Turning off the individual contour labelbar
;   - Manually creating lat/lon coordinate arrays 
;---------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"  

begin
;---Read in netCDF file
  in = addfile("/disk1/fhd/winter_forecast/data/t2m_wina_era5.nc","r")
  hind = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina_sys51.nc","r")
  old_hind = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina_2020.nc","r")
output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
outName =  "t2m_wina_era5_regrid.nc"

;---Read in data
  t2m = in->winter_anom
  longitude = hind->longitude
  latitude = hind->latitude 
  lon = old_hind->longitude
  lat = old_hind->latitude
;---------------------------------------------
; interpolate to new grid
;---------------------------------------------

  newlat = latitude
  newlon = longitude
  newlat@units = "degrees_north"
  newlon@units = "degrees_east"

  newsst = linint2_Wrap(lon,lat,t2m,True,newlon,newlat,0)

  newsst!0   ="time"
  newsst!1   = "latitude"
  newsst!2   = "longitude"
  newsst&latitude = newlat
  newsst&longitude = newlon
  newsst&time = hind&nyear
printVarSummary(newsst)

system("rm -f $output$+$outName$.nc")
 fout=addfile(output+outName, "c")
 fout->winter_anom=newsst

end
