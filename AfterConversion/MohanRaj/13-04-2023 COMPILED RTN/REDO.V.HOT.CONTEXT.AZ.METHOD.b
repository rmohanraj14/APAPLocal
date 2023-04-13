* @ValidationCode : MjoyMDg0ODIyMDk6Q3AxMjUyOjE2ODEzODgzNTY3NDA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:49:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.HOT.CONTEXT.AZ.METHOD
*-----------------------------------------------------------------------------
*COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*-------------
*DEVELOPED BY: Temenos Application Management
*-------------
*SUBROUTINE TYPE: NOFILE ROUTINE
*------------
*DESCRIPTION:
*------------
* This nofile routine will be attached to the enquiry REDO.ROU.CONTEXT.AZ.METHOD.ENQ.
*
*---------------------------------------------------------------------------
* Input / Output
*----------------
*
* Input / Output
* IN     : -na-
* OUT    : Y.FIN.ARR
*
*------------------------------------------------------------------------------------------------------------
* Revision History
* Date           Who                Reference              Description
* 09-SEP-2011   Marimuthu S        PACS00121111
* 23-SEP-2011   Marimuthu S        PACS00121130
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.MTS.DISBURSE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AZ.ACCOUNT


MAIN:

    GOSUB PROCESS
    GOSUB PGM.END

PROCESS:


    FN.REDO.MTS.DISBURSE = 'F.REDO.MTS.DISBURSE'
    F.REDO.MTS.DISBURSE = ''
    CALL OPF(FN.REDO.MTS.DISBURSE,F.REDO.MTS.DISBURSE)

    APPLN = 'AZ.ACCOUNT'
    FLD = 'L.AZ.METHOD.PAY'
    CALL MULTI.GET.LOC.REF(APPLN,FLD,POSS)
    Y.PAY.POS = POSS<1,1>
    NO.OF.REC = ''


    Y.COMI = COMI
    Y.CUS.ID = R.NEW(AZ.CUSTOMER)
    Y.PRINC.AMT = R.NEW(AZ.PRINCIPAL)
    Y.MET.PAY = R.NEW(AZ.LOCAL.REF)<1,Y.PAY.POS>
    IF MESSAGE NE 'VAL' THEN
        Y.COMI = Y.MET.PAY
    END

    IF Y.COMI EQ 'FROM.DISBURSEMENT' THEN
        SEL.CMD = 'SELECT ':FN.REDO.MTS.DISBURSE:' WITH CUSTOMER.NO EQ ':Y.CUS.ID:' AND AMOUNT EQ ':Y.PRINC.AMT:' AND AZ.ACCT.STATUS EQ AUTHORISED'
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,SEL.ERR)
        IF NO.OF.REC EQ '' OR NO.OF.REC EQ 0 THEN
            AF = AZ.LOCAL.REF
            AV = Y.PAY.POS
            ETEXT = 'EB-NO.REC'
            CALL STORE.END.ERROR
        END

    END

RETURN

PGM.END:


END
