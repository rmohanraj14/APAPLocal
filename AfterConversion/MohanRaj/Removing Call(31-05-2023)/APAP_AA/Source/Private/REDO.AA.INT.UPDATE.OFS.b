* @ValidationCode : Mjo4MTk1NzQwNTQ6Q3AxMjUyOjE2ODM2OTg0MjIwMTQ6SVRTUzotMTotMToyODY6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 286
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.INT.UPDATE.OFS(Y.OUT.MESSAGE)
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.AA.INT.UPDATE.OFS
*--------------------------------------------------------------------------------
* Description: This is out message routine to OFS.SOURCE used to update the live template
* incase of failure.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE          DESCRIPTION
* 19-May-2011   H GANESH      PACS00055012 - B.16  INITIAL CREATION
* Date                 who                   Reference              
* 29-03-2023          CONVERSTION TOOL      R22 AUTO CONVERSTION - No Change
* 29-03-2023          ANIL KUMAR B      R22 MANUAL CONVERSTION -NO CHANGES
*
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------

    Y.PART.1 = FIELD (Y.OUT.MESSAGE,',',1)
    Y.FT.ID = FIELD(Y.PART.1,'/',1)
    Y.FT.ID ='AAA':FIELD(Y.FT.ID,'AAA',2)
    Y.MSG.ID = FIELD (Y.PART.1,'/',2)
    Y.RESULT = FIELD(Y.PART.1,'/',3)
    GOSUB UPDATE.CONCAT

RETURN
*---------------------------------------------------------------------------------
UPDATE.CONCAT:
*---------------------------------------------------------------------------------
    FN.REDO.AA.OFS.FAIL='F.REDO.AA.OFS.FAIL'
    F.REDO.AA.OFS.FAIL=''

    CALL OPF(FN.REDO.AA.OFS.FAIL,F.REDO.AA.OFS.FAIL)
    CALL F.READ(FN.REDO.AA.OFS.FAIL,TODAY,R.OFS.FAIL,F.REDO.AA.OFS.FAIL,OFS.FAIL.ERR)
    IF R.OFS.FAIL EQ '' THEN
        R.OFS.FAIL<1>=Y.FT.ID:'-':Y.MSG.ID
    END ELSE
        R.OFS.FAIL<-1>=Y.FT.ID:'-':Y.MSG.ID

    END
    CALL F.WRITE(FN.REDO.AA.OFS.FAIL,TODAY,R.OFS.FAIL)

RETURN
END
