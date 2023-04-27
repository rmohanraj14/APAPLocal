* @ValidationCode : Mjo1MDI4ODY2MTpDcDEyNTI6MTY4MTM4MDg2MDQ4ODpJVFNTOi0xOi0xOjQ5NzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:20
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 497
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INVST.ACCT.RTN
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.INVST.ACCT.RTN
*--------------------------------------------------------------------------------------------------------
*Description       : This is a CONVERSION routine attached to an enquiry, the routine fetches the
*                    from account and limit application and returns it to O.DATA
*Linked With       : Enquiry ENQ.REDO.OVERDRAFT.ACCOUNT
*In  Parameter     : N/A
*Out Parameter     : N/A
*Files  Used       : N/A
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date           Who               Reference                                 Description
*     ------         -----             -------------                             -------------
* 16 NOV 2010       NATCHIMUTHU.P        ODR-2010-03-0089                         Initial Creation
* 11-APR-2023     Conversion tool    R22 Auto conversion    			   No changes
** 11-APR-2023      Harishvikram C   Manual R22 conversion                 No changes
*********************************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AC.ACCOUNT.LINK

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AC.ACCOUNT.LINK.CONCAT = 'F.AC.ACCOUNT.LINK.CONCAT'
    F.AC.ACCOUNT.LINK.CONCAT  = ''
    CALL OPF(FN.AC.ACCOUNT.LINK.CONCAT,F.AC.ACCOUNT.LINK.CONCAT)

    FN.AC.ACCOUNT.LINK  = "F.AC.ACCOUNT.LINK"
    F.AC.ACCOUNT.LINK   = ''
    CALL OPF(FN.AC.ACCOUNT.LINK,F.AC.ACCOUNT.LINK)

    ACCOUNT.ID = O.DATA
    ACCOUNT.ID.NULL = ''

    CALL F.READ(FN.AC.ACCOUNT.LINK.CONCAT,ACCOUNT.ID,R.AC.ACCOUNT.LINK.CONCAT,F.AC.ACCOUNT.LINK.CONCAT,AC.ACCOUNT.LINK.CONCAT.ERR)
    Y.ACCT.LINK = R.AC.ACCOUNT.LINK.CONCAT

    CALL F.READ(FN.AC.ACCOUNT.LINK,Y.ACCT.LINK,R.ACCT.LINK,F.AC.ACCOUNT.LINK,ACCT.LINK.ERR)
    Y.SWEEP.TYPE  = R.ACCT.LINK<AC.LINK.SWEEP.TYPE>
    Y.TO.ACCOUNT =  R.ACCT.LINK<AC.LINK.ACCOUNT.TO>

    IF Y.SWEEP.TYPE EQ 'SURP' THEN
        O.DATA = Y.TO.ACCOUNT
    END ELSE
        O.DATA = ACCOUNT.ID.NULL
    END

RETURN
END
*---------------------------------------------------------------------------------------------------------------------
* PROGRAM END
*----------------------------------------------------------------------------------------------------------------------
