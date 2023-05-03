* @ValidationCode : MjoyMTAxNzY5MzI6Q3AxMjUyOjE2ODIwNzI4OTEzMDc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:58:11
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     I TO I.VAR,= TO EQ
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CUSTOMER.NON.JOINT.HOLDER(ACC.ID,RES)

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT.CLOSURE

    FN.AZ = "F.AZ.ACCOUNT$HIS"
    F.AZ = ""
    CALL OPF(FN.AZ,F.AZ)

    FN.CLOSURE = "F.ACCOUNT.CLOSURE"
    F.CLOSURE = ""
    CALL OPF(FN.CLOSURE,F.CLOSURE)

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.ACC.HIS = "F.ACCOUNT$HIS"
    F.ACC.HIS = ""
    CALL OPF(FN.ACC.HIS,F.ACC.HIS)


    CALL F.READ(FN.CLOSURE,ACC.ID,R.CLOSURE,F.CLOSURE,ERR.CLOSURE)
    SETTLEMENT = R.CLOSURE<AC.ACL.SETTLEMENT.ACCT>

    IF SETTLEMENT[1,3] EQ "DOP" OR SETTLEMENT EQ "" THEN

        CALL F.READ.HISTORY(FN.AZ,ACC.ID,R.AZ,F.AZ,ERR.AZ)
        SETTLEMENT = R.AZ<AZ.INTEREST.LIQU.ACCT>

    END


    CALL F.READ(FN.ACCOUNT,SETTLEMENT,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    JOINT.HOLDER = R.ACCOUNT<AC.JOINT.HOLDER>
    RELATION.CODE = R.ACCOUNT<AC.RELATION.CODE>


*   In account is reinv
    IF ERR.ACCOUNT THEN

        CALL F.READ(FN.CLOSURE,SETTLEMENT,R.CLOSURE,F.CLOSURE,ERR.CLOSURE)
        SETTLEMENT = R.CLOSURE<AC.ACL.SETTLEMENT.ACCT>

        CALL F.READ(FN.ACCOUNT,SETTLEMENT,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
        JOINT.HOLDER = R.ACCOUNT<AC.JOINT.HOLDER>
        RELATION.CODE = R.ACCOUNT<AC.RELATION.CODE>

    END


    M.VAR = DCOUNT(JOINT.HOLDER,@VM) ;*R22 Auto code conversion
    FOR A = 1 TO M.VAR STEP 1

        IF RELATION.CODE<1,A> EQ 500 OR RELATION.CODE<1,A> EQ 501 THEN
            RES = JOINT.HOLDER<1,A>
            BREAK;
        END ELSE
            RES = ""
        END

    NEXT A


*   DEBUG

    IF ERR.ACCOUNT THEN
        RES = ""
    END

    IF JOINT.HOLDER EQ "" THEN
        RES = ""
    END


*  DEBUG

RETURN


END
