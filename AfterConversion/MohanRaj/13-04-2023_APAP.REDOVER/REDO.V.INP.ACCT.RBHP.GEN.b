* @ValidationCode : Mjo1NTgxODY5Mjk6Q3AxMjUyOjE2ODEzODg3NjkzNjk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:56:09
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
SUBROUTINE REDO.V.INP.ACCT.RBHP.GEN
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Marimuthu S (TAM)
* Program Name  : REDO.V.INP.ACCT.RBHP.GEN
*-------------------------------------------------------------------------
* Description:
*-------------------------------------------------------------------------
* Linked with   :
* In parameter  :
* out parameter :
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*------------------------------------------------------------------------
*   DATE              ODR / HD REF                  DESCRIPTION
* 13-02-2013
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,IF Condition Added,FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SPF
    $INSERT I_System
    $INSERT I_F.ACCOUNT

    $INSERT I_F.REDO.ACCT.EXCE.RBHP
    $INSERT I_F.REDO.EXCEP.REC.PARAM


    GOSUB OPEN.PROCESS
    GOSUB GET.PARAM.VALUE

    IF Y.APP.FOUND EQ 'Y' THEN
        GOSUB PROCESS
    END


RETURN

*------------
OPEN.PROCESS:
*------------

    FN.REDO.ACCT.EXCE.RBHP = 'F.REDO.ACCT.EXCE.RBHP'
    F.REDO.ACCT.EXCE.RBHP = ''
    CALL OPF(FN.REDO.ACCT.EXCE.RBHP,F.REDO.ACCT.EXCE.RBHP)

    FN.REDO.EXCEP.REC.PARAM = 'F.REDO.EXCEP.REC.PARAM'

    Y.APP.FOUND = ''

RETURN
*---------------
GET.PARAM.VALUE:
*---------------

    PARAM.ID = 'SYSTEM'

    CALL CACHE.READ(FN.REDO.EXCEP.REC.PARAM,PARAM.ID,R.REDO.EXCEP.REC.PARAM,PARAM.ERR)

    Y.RBHP.APP = R.REDO.EXCEP.REC.PARAM<EXCEP.RBHP.APPS>
    CHANGE @VM TO @FM IN Y.RBHP.APP

    LOCATE APPLICATION IN Y.RBHP.APP SETTING POS THEN
        Y.APP.FOUND = 'Y'
    END ELSE
        Y.APP.FOUND = 'N'
    END

RETURN
*--------
PROCESS:
*--------

    CURRNT.COMP = System.getVariable("CURRENT.USER.BRANCH")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        CURRNT.COMP = ""
    END ;*R22 Auto code conversion-END

    IF CURRNT.COMP EQ "CURRENT.USER.BRANCH" THEN
        LOCATE 'EB-UNKNOWN.VARIABLE' IN E<1,1> SETTING POS THEN
            E = ''
        END
        RETURN
    END

    Y.ID = APPLICATION:'-':CURRNT.COMP:'-':ID.NEW
    R.REDO.ACCT.EXCE.RBHP = ID.NEW
    CALL F.WRITE(FN.REDO.ACCT.EXCE.RBHP,Y.ID,R.REDO.ACCT.EXCE.RBHP)

RETURN
*--------------------------------------
END
