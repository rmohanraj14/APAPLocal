* @ValidationCode : MjotMTM5MDI0MTMzOTpDcDEyNTI6MTY4MTM4MDg2MzQwNTpJVFNTOi0xOi0xOjM3OToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 379
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.GETTPDET
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :RMONDRAGON
*Program   Name    :REDO.IVR.GETTPDET
*---------------------------------------------------------------------------------
*DESCRIPTION       :It is routine to get the third party details for payment from IVR
*
*LINKED WITH       :
*
* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 12-MAR-2013      RMONDRAGON     ODR-2010-08-0031      Initial Version
* 11-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.ADD.THIRDPARTY
    $INSERT I_F.REDO.THIRDPRTY.PARAMETER

    GOSUB INIT
    GOSUB PROCESS

RETURN

*----
INIT:
*----

    FN.REDO.ADD.THIRDPARTY = 'F.REDO.ADD.THIRDPARTY'
    F.REDO.ADD.THIRDPARTY = ''
    CALL OPF(FN.REDO.ADD.THIRDPARTY,F.REDO.ADD.THIRDPARTY)

    FN.REDO.THIRDPRTY.PARAMETER = 'F.REDO.THIRDPRTY.PARAMETER'
    F.REDO.THIRDPRTY.PARAMETER = ''
    CALL OPF(FN.REDO.THIRDPRTY.PARAMETER,F.REDO.THIRDPRTY.PARAMETER)

    LREF.APP = 'FUNDS.TRANSFER'
    LREF.FIELDS = 'L.FT.CMPNY.ID':@VM:'L.FT.BILL.TYPE':@VM:'L.FT.BILL.COND':@VM:'L.FT.PARTY.NAME'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    L.FT.CMPNY.ID.POS=LREF.POS<1,1>
    L.FT.BILL.TYPE.POS=LREF.POS<1,2>
    L.FT.BILL.COND.POS=LREF.POS<1,3>
    L.FT.PARTY.NAME.POS=LREF.POS<1,4>

*-------
PROCESS:
*-------

    Y.CONTRACT.NO = COMI

    SEL.CMD.RCO = "SELECT ":FN.REDO.ADD.THIRDPARTY:" WITH CONTRACT.NO EQ " :Y.CONTRACT.NO
    CALL EB.READLIST(SEL.CMD.RCO,SEL.LIST,'',NO.OF.REC,SEL.ERR)

    IF NO.OF.REC EQ 1 THEN
        TP.ID = SEL.LIST<1>
        R.REDO.ADD.THIRDPARTY = ''; REDO.ADD.THIRDPARTY.ERR = ''
        CALL F.READ(FN.REDO.ADD.THIRDPARTY,TP.ID,R.REDO.ADD.THIRDPARTY,F.REDO.ADD.THIRDPARTY,REDO.ADD.THIRDPARTY.ERR)
        IF R.REDO.ADD.THIRDPARTY THEN
            R.NEW(FT.LOCAL.REF)<1,L.FT.CMPNY.ID.POS> = R.REDO.ADD.THIRDPARTY<ARC.TP.COMP.SERV.NAME>
            R.NEW(FT.LOCAL.REF)<1,L.FT.PARTY.NAME.POS> = R.REDO.ADD.THIRDPARTY<ARC.TP.CUSTOMER.NAME>
            GOSUB GET.VAL.TPPARAM
            R.NEW(FT.LOCAL.REF)<1,L.FT.BILL.TYPE.POS> = Y.BILL.TYPE
            R.NEW(FT.LOCAL.REF)<1,L.FT.BILL.COND.POS> = Y.BILL.COND
        END
    END

RETURN

*---------------
GET.VAL.TPPARAM:
*---------------

    Y.COMP.SERV.NAME = R.REDO.ADD.THIRDPARTY<ARC.TP.COMP.SERV.NAME>

    SEL.RTP.CMD = "SELECT ":FN.REDO.THIRDPRTY.PARAMETER:" WITH COMP.NAME EQ '":Y.COMP.SERV.NAME:"'"
    CALL EB.READLIST(SEL.RTP.CMD,SEL.RTP.LIST,'',NO.OF.RTP.REC,SEL.RTP.ERR)

    IF NO.OF.RTP.REC EQ 1 THEN
        Y.ID = SEL.RTP.LIST<1>
        R.REDO.THIRDPRTY.PARAMETER = ''; REDO.ERR = ''
        CALL F.READ(FN.REDO.THIRDPRTY.PARAMETER,Y.ID,R.REDO.THIRDPRTY.PARAMETER,F.REDO.THIRDPRTY.PARAMETER,REDO.ERR)
        IF R.REDO.THIRDPRTY.PARAMETER THEN
            Y.BILL.TYPE = R.REDO.THIRDPRTY.PARAMETER<REDO.TP.BILL.TYPE>
            Y.BILL.COND = R.REDO.THIRDPRTY.PARAMETER<REDO.TP.BILL.COND>
        END
    END

RETURN

END
