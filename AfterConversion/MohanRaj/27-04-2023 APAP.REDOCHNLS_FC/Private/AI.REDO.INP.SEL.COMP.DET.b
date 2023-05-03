* @ValidationCode : MjotMjk1OTI3MTg2OkNwMTI1MjoxNjgxMzgwNzg1ODQ3OklUU1M6LTE6LTE6OTI6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:05
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 92
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.INP.SEL.COMP.DET

*-----------------------------------------------------------------------------
* @author riyasbasha@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 11-APR-2023      Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.THIRDPRTY.PARAMETER
    $INSERT I_F.REDO.ADD.THIRDPARTY


    FN.REDO.THIRDPRTY.PARAMETER = 'F.REDO.THIRDPRTY.PARAMETER'
    F.REDO.THIRDPRTY.PARAMETER  = ''
    CALL OPF(FN.REDO.THIRDPRTY.PARAMETER,F.REDO.THIRDPRTY.PARAMETER)
    GOSUB PROCESS

RETURN
*********
PROCESS:
*********

    Y.COMP.NAME  = R.NEW(ARC.TP.COMP.SERV.NAME)
    SEL.CMD.RCO = "SELECT ":FN.REDO.THIRDPRTY.PARAMETER:" WITH COMP.NAME EQ ":Y.COMP.NAME
    CALL EB.READLIST(SEL.CMD.RCO,SEL.LIST,'',NO.OF.REC,SEL.ERR)
    R.NEW(ARC.TP.TYPE.OF.SERVICE) = SEL.LIST<1>
RETURN
*-----------------------------------------------------------------------------
END
