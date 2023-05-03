* @ValidationCode : Mjo5NTU1NTEyMDA6Q3AxMjUyOjE2ODE3MzM2OTIxNDY6SVRTUzotMTotMTowOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.RESP.TWS2(Y.RESPONSE)
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is a routine to simplify the error messages through IVR.
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who                   Reference               Description
*  16-DEC-2014   RMONDRAGON             ODR-2011-02-0099        INITIAL VERSION
*
* 11-APR-2023     Conversion tool   R22 Auto conversion        ++ to +=
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
* </region>
*-----------------------------------------------------------------------------

    Y.SAME.ERROR.DISP = 0

    Y.RESP.1 = FIELD(Y.RESPONSE,',',2)
    Y.RESP.2 = FIELD(Y.RESPONSE,',',3)
    Y.RESP.3 = 'ADATA:1:2=ERROR*NO/'

    IF Y.RESP.2 EQ 'ADATA:1:1=RET_CODE*2' THEN
        Y.RESP.VAL.2 = FIELD(Y.RESPONSE,',',4)
        Y.RESP.VAL.2 = FIELD(Y.RESP.VAL.2,'ADATA:1:2=ERROR*NO/',2)
        Y.TOT.ERROR.DISP = DCOUNT(Y.RESP.VAL.2,'/')
        Y.ERROR = FIELD(Y.RESP.VAL.2,'/',1)
        Y.CNT.ERROR.DISP = 2
        LOOP
        WHILE Y.CNT.ERROR.DISP LE Y.TOT.ERROR.DISP
            Y.ERROR2 = FIELD(Y.RESP.VAL.2,'/',Y.CNT.ERROR.DISP)
            IF Y.ERROR EQ Y.ERROR2 THEN
                Y.SAME.ERROR.DISP += 1
            END ELSE
                Y.ADD.ERROR := '/'Y.ERROR2
            END
            Y.CNT.ERROR.DISP += 1
        REPEAT

        IF Y.TOT.ERROR.DISP EQ Y.SAME.ERROR.DISP THEN
            Y.RESPONSE = ',':Y.RESP.1:',':Y.RESP.2:',':Y.RESP.3:Y.ERROR
        END ELSE
            Y.RESPONSE = ',':Y.RESP.1:',':Y.RESP.2:',':Y.RESP.3:Y.ERROR:Y.ADD.ERROR
        END
    END

RETURN

END
