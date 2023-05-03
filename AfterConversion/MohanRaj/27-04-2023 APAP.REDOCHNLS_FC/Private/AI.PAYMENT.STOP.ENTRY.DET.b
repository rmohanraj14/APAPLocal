* @ValidationCode : MjoxOTI3NzkxMDE3OkNwMTI1MjoxNjgxMzgwNzg0MjM0OklUU1M6LTE6LTE6NTgwOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 580
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS

SUBROUTINE AI.PAYMENT.STOP.ENTRY.DET
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PAYMENT.STOP
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_F.STMT.ENTRY
    $INSERT I_ENQUIRY.COMMON

    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------
OPENFILES:
*-----------------------------------------

    FN.PAYMENT.STOP = 'F.PAYMENT.STOP'
    F.PAYMENT.STOP = ''
    CALL OPF(FN.PAYMENT.STOP,F.PAYMENT.STOP)

    FN.STMT.ENTRY = 'F.STMT.ENTRY'
    F.STMT.ENTRY = ''
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)

    FN.PAYMENT.STOP.HIST = 'F.PAYMENT.STOP$HIS'
    F.PAYMENT.STOP.HIST = ''
    CALL OPF(FN.PAYMENT.STOP.HIST,F.PAYMENT.STOP.HIST)

    FN.PAYMENT.STOP.STMT = 'F.PAYMENT.STOP.STMT'
    F.PAYMENT.STOP.STMT  = ''
    CALL OPF(FN.PAYMENT.STOP.STMT,F.PAYMENT.STOP.STMT)

    LREF.APPLN="PAYMENT.STOP"
    LREF.FIELDS="L.PS.STOP.REF"
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APPLN,LREF.FIELDS,LREF.POS)
    POS.L.PS.STOP.REF = LREF.POS<1,1>

RETURN
*-----------------------------------------
PROCESS:
*-----------------------------------------

    Y.FLAG = ''
    Y.O.DATA=O.DATA
    CALL F.READ(FN.STMT.ENTRY,Y.O.DATA,R.STMT.ENTRY,F.STMT.ENTRY,STMT.ENTRY.ERR)
    Y.STMT.TRANS.REF = FIELD(R.STMT.ENTRY<AC.STE.TRANS.REFERENCE>,'.',1)
    Y.STMT.NO = TRIM(R.STMT.ENTRY<AC.STE.STMT.NO,1>)
    IF Y.STMT.TRANS.REF EQ 'PS' THEN
        Y.FLAG = 1
    END ELSE
        O.DATA = FIELD(R.STMT.ENTRY<AC.STE.TRANS.REFERENCE>,'\',1)
    END

    IF Y.FLAG THEN
        CALL F.READ(FN.PAYMENT.STOP.STMT,Y.STMT.NO,R.PAYMENT.STOP.STMT,F.PAYMENT.STOP.STMT,PAYMENT.STOP.STMT.ERR)
        IF R.PAYMENT.STOP.STMT THEN
            O.DATA = 'PS':'.':R.PAYMENT.STOP.STMT
        END ELSE
            O.DATA = FIELD(R.STMT.ENTRY<AC.STE.TRANS.REFERENCE>,'\',1)
        END
    END

RETURN
*-----------------------------------------
PGM.END:
END
