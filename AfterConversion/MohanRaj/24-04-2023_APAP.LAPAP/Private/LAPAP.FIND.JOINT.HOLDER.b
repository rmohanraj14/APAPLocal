* @ValidationCode : MjozNjUyOTMxNTA6Q3AxMjUyOjE2ODIzMTk1MzA2NTI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 24 Apr 2023 12:28:50
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
*24-04-2023      conversion tool     R22 Auto code conversion     No changes
*24-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
SUBROUTINE LAPAP.FIND.JOINT.HOLDER

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT

    FN.ACC = "F.ACCOUNT"
    F.ACC = ""
    CALL OPF(FN.ACC,F.ACC)

    FN.HIS = "F.ACCOUNT$HIS"
    F.HIS = ""
    CALL OPF(FN.HIS,F.HIS)

*-----------------------
* Verifying Account type
*-----------------------

    ACC = COMI
    CALL LAPAP.VERIFY.ACC(ACC,RES)
    Y.ACC.ID = RES

* DEBUG

*-------------------------
* If Account is a reinvest
*-------------------------


    IF ACC NE Y.ACC.ID THEN

        CALL F.READ(FN.ACC,Y.ACC.ID,R.ACC,F.ACC,ERR)
        JOINT.HOLDER = R.ACC<AC.JOINT.HOLDER,1>
        RELATION.CODE = R.ACC<AC.RELATION.CODE,1>

        IF RELATION.CODE EQ 500 OR RELATION.CODE EQ 501 THEN
            COMI = JOINT.HOLDER
        END ELSE
*           COMI = ""

            CALL APAP.LAPAP.LAPAP.CUSTOMER.NON.JOINT.HOLDER(Y.ACC.ID,RES) ;*R22 Manual Code Conversion
            COMI = RES
        END

        RETURN


    END ELSE

*---------------------------
* If account is not reinvest
*---------------------------

        CALL F.READ(FN.ACC,ACC,R.ACC,F.ACC,ERR.noreinv)
        JOINT.HOLDER = R.ACC<AC.JOINT.HOLDER,1>
        RELATION.CODE = R.ACC<AC.RELATION.CODE,1>

        IF RELATION.CODE EQ 500 OR RELATION.CODE EQ 501 THEN
            COMI = JOINT.HOLDER
        END ELSE
*           COMI = ""
            CALL APAP.LAPAP.LAPAP.CUSTOMER.NON.JOINT.HOLDER(ACC,RES) ;*R22 Manual Code Conversion
            COMI = RES
        END



        IF ERR.noreinv THEN

*---------------------------------------------
* If account not reinvest is closed via teller
*---------------------------------------------

            CALL F.READ.HISTORY(FN.HIS,ACC,R.HIS,F.HIS,ERRH)
            JOINT.HOLDER.HIS = R.HIS<AC.JOINT.HOLDER,1>
            RELATION.CODE.HIS = R.HIS<AC.RELATION.CODE,1>

            IF RELATION.CODE.HIS EQ 500 OR RELATION.CODE.HIS EQ 501 THEN
                COMI = JOINT.HOLDER.HIS
            END ELSE
*               COMI = ""
                ACC = ACC[1,10]
                CALL APAP.LAPAP.LAPAP.CUSTOMER.NON.JOINT.HOLDER(ACC,RES) ;*R22 Manual Code Conversion
                COMI = RES
            END
        END

    END


*   if ACC is reinvest and category type 6601 != 6010-6020
    IF NOT(ERR) AND ERR.noreinv AND ERRH THEN
        Y.ACC = Y.ACC.ID[1,10]
        CALL APAP.LAPAP.LAPAP.CUSTOMER.NON.JOINT.HOLDER(Y.ACC.ID,RES) ;*R22 Manual Code Conversion
    END



END
