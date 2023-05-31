MERGE climate-delta-dev.speed_datamart_bkp.tblRain replica
using(
select Code_WBAN,Dates,Measure,Info,QC,datatype,IDUserCreate,IDUserUpdate,IDSource,CreateDate,UpdateDate,op,source_ts_ms
from
(SELECT   Code_WBAN,Dates,Measure,Info,QC,datatype,IDUserCreate,IDUserUpdate,IDSource,CreateDate,UpdateDate,op,source_ts_ms,
        row_number() OVER (partition BY Code_WBAN,Dates,datatype ORDER BY source_ts_ms DESC) AS row_num
FROM  `climate-delta-dev.speedwell_stage.tblRain`)
WHERE  row_num=1) staging
on replica.code_wban = staging.code_wban and  replica.Dates = staging.Dates and replica.datatype = staging.datatype
WHEN MATCHED AND staging.op = 'd'
THEN DELETE
WHEN MATCHED AND staging.op = 'u' 
THEN UPDATE
SET 
`Code_WBAN` = staging.Code_WBAN,
`Dates`  = staging.Dates,
`Measure` = staging.Measure,
`Info` = staging.Info,
`QC` = staging.QC,
`datatype` = staging.datatype,
`IDUserCreate` = staging.IDUserCreate,
`IDUserUpdate` =staging.IDUserUpdate,
`IDSource` = staging.IDSource,
`CreateDate` = staging.CreateDate,
`UpdateDate` = staging.UpdateDate
WHEN NOT matched BY target and staging.op != 'd'
THEN INSERT(`Code_WBAN`,`Dates`,`Measure`,`Info`,`QC`,`datatype`,`IDUserCreate`,`IDUserUpdate`,`IDSource`,`CreateDate`,`UpdateDate`)
VALUES (staging.Code_WBAN,staging.Dates,staging.Measure,staging.Info,staging.QC,staging.datatype,staging.IDUserCreate,staging.IDUserUpdate,staging.IDSource,staging.CreateDate,staging.UpdateDate)