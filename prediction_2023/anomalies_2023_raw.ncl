begin

; ==============================================================
 output  =  "/disk1/fhd/winter_forecast/data/"                            ; directory for plot output
 outName = "prediction_raw_2023.nc" 
; anomalies for t2m 2022
; ==============================================================
climatalogy = addfile("/disk1/fhd/winter_forecast/data/t2m_in11_6mon_wina_sys51.nc","r")
cli=climatalogy->winter_cli
varname     = "2T_GDS0_SFC"
files_dir    = "/disk4/mssfs/forecast/ecmwf/sys51/10/monthly/surface/t2m.2023.grib"                            ; input directory
varible_file      = addfile (files_dir, "r")
var=varible_file->$varname$
seasonal=dim_avg_n(var(:,2:4,:,:),1)
ensemble = dim_avg_n(seasonal,0)
anomaly = ensemble-cli
printMinMax(cli,False)
printMinMax(var,False)
printMinMax(anomaly,False)
; ==============================================================
; anomalies for sst 2022
; ==============================================================
climatalogy1 = addfile("/disk1/fhd/winter_forecast/data/sst_in11_6mon_wina_sys51.nc","r")
cli1=climatalogy1->winter_cli
varname1     = "SSTK_GDS0_SFC"
files_dir1    = "/disk4/mssfs/forecast/ecmwf/sys51/10/monthly/surface/sst.2023.grib"                            ; input directory
varible_file1      = addfile (files_dir1, "r")
var1=varible_file1->$varname1$
seasonal1=dim_avg_n(var1(:,2:4,:,:),1)
ensemble1 = dim_avg_n(seasonal1,0)
anomaly1 = ensemble1-cli1

; ==============================================================
; anomalies for sic 2022
; ==============================================================
climatalogy2 = addfile("/disk1/fhd/winter_forecast/data/sic_in11_6mon_wina_sys51.nc","r")
cli2=climatalogy2->winter_cli
varname2     = "CI_GDS0_SFC"
files_dir2    = "/disk4/mssfs/forecast/ecmwf/sys51/10/monthly/surface/sic.2023.grib"                            ; input directory
varible_file2      = addfile (files_dir2, "r")
var2=varible_file2->$varname2$
var2 = where(var2.eq.0, var2@_FillValue, var2)
seasonal2=dim_avg_n(var2(:,2:4,:,:),1)
ensemble2 = dim_avg_n(seasonal2,0)
anomaly2 = ensemble2-cli2

; ==============================================================
; anomalies for sd 2022
; ==============================================================
climatalogy3 = addfile("/disk1/fhd/winter_forecast/data/sd_in11_6mon_wina_sys51.nc","r")
cli3=climatalogy3->winter_cli
varname3     = "SD_GDS0_SFC"
files_dir3    = "/disk4/mssfs/forecast/ecmwf/sys51/10/monthly/surface/sd.2023.grib"                            ; input directory
varible_file3      = addfile (files_dir3, "r")
var3=varible_file3->$varname3$
var3 = where(var3.lt.0.000001, var3@_FillValue, var3)
var3 = var3*1000 
seasonal3=dim_avg_n(var3(:,2:4,:,:),1)
ensemble3 = dim_avg_n(seasonal3,0)
anomaly3 = ensemble3-cli3

copy_VarCoords(cli1,anomaly)
copy_VarCoords(cli1,anomaly1)
copy_VarCoords(cli1,anomaly2)
copy_VarCoords(cli1,anomaly3)

;print(anomaly1)
system("rm -f $output$+$outName$.nc")
fout=addfile(output+outName, "c")
fout->t2m=anomaly
fout->sst=anomaly1
fout->sic=anomaly2
fout->sd=anomaly3


end

