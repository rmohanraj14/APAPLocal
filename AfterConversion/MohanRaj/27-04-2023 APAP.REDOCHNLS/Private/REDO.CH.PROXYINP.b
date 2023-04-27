* @ValidationCode : MjotMTEwMDA3OTQzMzpDcDEyNTI6MTY4MTIxNTE2NjM0NTpJVFNTOi0xOi0xOjczOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 73
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.PROXYINP
**
* Subroutine Type : VERSION
* Attached to     : AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXINP
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Create the ISA and external user for corporate inputter user
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 29/08/12 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 12/04/13 - Second Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 10-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
*    $INCLUDE TAM.BP I_REDO.CH.V.EMAIL.COMMON

    IF OFS.VAL.ONLY EQ '' THEN
*        IF SENDMAIL EQ 'Y' THEN
        GOSUB OPEN.FILES
        GOSUB INIT
        GOSUB PROCESS
*        END ELSE
*            SENDMAIL = 0
*        END
    END

RETURN

***********
OPEN.FILES:
***********

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

RETURN

*****
INIT:
*****

    LREF.APP = 'AA.ARRANGEMENT.ACTIVITY'
    LREF.FIELDS = 'ARC.USR.ID':@VM:'L.EB.PROXY.ARR':@VM:'L.CORP.EMAIL'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    ARC.USR.ID.POS = LREF.POS<1,1>
    CUS.POS = LREF.POS<1,2>
    L.CORP.EMAIL.POS = LREF.POS<1,3>

    OFS.SRC = 'CHADMONPROC'

RETURN

********
PROCESS:
********

    Y.CUS.COMP = R.NEW(AA.ARR.ACT.CUSTOMER)
    Y.CUS = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,CUS.POS>
    Y.USR = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,ARC.USR.ID.POS>
    Y.EMAIL.REG = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,L.CORP.EMAIL.POS>
    Y.PROXY = R.NEW(AA.ARR.ACT.ARRANGEMENT)
*    R.NEW(AA.ARR.ACT.LOCAL.REF)<1,CUS.POS> = ''
*    R.NEW(AA.ARR.ACT.LOCAL.REF)<1,L.CORP.EMAIL.POS> = ''

    IF Y.EMAIL.REG EQ '' THEN
        AF = AA.ARR.ACT.LOCAL.REF
        AV = L.CORP.EMAIL.POS
        ETEXT = 'EB-REDO.NOT.MAIL'
        CALL STORE.END.ERROR
        RETURN
    END


    OFS.HEADER = 'AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWINTINP/I/PROCESS//0/,//DO0010001/////,,'
    OFS.BODY := 'CUSTOMER:1:1=' : Y.CUS : ','
    OFS.BODY := 'ARC.USR.ID:1:1=' : Y.USR : ','
    OFS.BODY := 'PROPERTY:1:1=USERRIGHTS,'
    OFS.BODY := 'FIELD.NAME:1:1=ALLOWED.CUSTOMER:1:1,'
    OFS.BODY := 'FIELD.NAME:1:2=PROXY.ARRANGEMENT:1:1,'
    OFS.BODY := 'FIELD.VALUE:1:1=' : Y.CUS.COMP :','
    OFS.BODY := 'FIELD.VALUE:1:2=' : Y.PROXY :','
    OFS.BODY := 'L.CORP.EMAIL:1:1=' : Y.EMAIL.REG :','

    OFS.MSG = OFS.HEADER : OFS.BODY

    TXN.COMM = ''
    CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG,RESP.OFS.MSG,TXN.COMM)

RETURN

END
