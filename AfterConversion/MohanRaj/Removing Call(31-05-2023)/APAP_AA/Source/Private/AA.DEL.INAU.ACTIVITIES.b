* @ValidationCode : MjoxMzk0NzU1MTk2OkNwMTI1MjoxNjgzNjk4NDE3OTQyOklUU1M6LTE6LTE6MTQ2ODoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 1468
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
PROGRAM AA.DEL.INAU.ACTIVITIES

*-----------------------------------------------------------------------------------
* Modification History:
*
*DATE                 WHO                  REFERENCE                    DESCRIPTION
* 28/03/2023         SURESH        MANUAL R22 CODE CONVERSION        Package Name added APAP.AA
* 28/03/2023       Conversion Tool     AUTO R22 CODE CONVERSION          = to EQ
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS

* DATE     : 17-02-2012
* WRITE BY : Duggineni Haribabu
* CLIENT   : APAP
* PURPOSE  : In APAP Client area for some of the AA.ARR.PAYMENT.SCHEDULE live records and
* INAU record we don't have the BASE.DATE. Using this routine we will identify those
* problamatic AA.ARR.PAYMENT.SCHEDULE record and we will get the corresponding BASE.DATE
* and we will update to it to AA.ARR.PAYMENT.SCHEDULE accordingly
 
    EXECUTE "COMO ON AA.DEL.INAU.ACTIVITIES"        ;* COMO for further reference
    GOSUB INITIALISE
    GOSUB PROCESS
    EXECUTE "COMO OFF AA.DEL.INAU.ACTIVITIES"

INITIALISE:

* Open the necessary files and initialise the necessary varialbes

    FN.ARR.PS = "F.AA.ARR.PAYMENT.SCHEDULE"
    F.ARR.PS = ""
    CALL OPF(FN.ARR.PS, F.ARR.PS)

    FN.ARR.PS$NAU = "F.AA.ARR.PAYMENT.SCHEDULE$NAU"
    F.ARR.PS$NAU = ""
    CALL OPF(FN.ARR.PS$NAU, F.ARR.PS$NAU)

    FN.AA.ARG = "F.AA.ARRANGEMENT"
    F.AA.ARG = ""
    CALL OPF(FN.AA.ARG, F.AA.ARG)

    FN.AA.ACC = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACC = ""
    CALL OPF(FN.AA.ACC, F.AA.ACC)

    SEL.LIST = ""
    ID.LIST = ""
    ID.SELECTED = ""
    Y.ID = ""
    Y.ARR.REC = ""
    ERR = ""
    REC.CNT = 1

RETURN

PROCESS:

    GOSUB PROCESS.LIVE
    GOSUB PROCESS.UNAUTH
    CALL JOURNAL.UPDATE("")
RETURN

PROCESS.LIVE:

* Select the BASE.DATE eq NULL reocrds from AA.ARR.PAYMENT.SCHEDULE

    CALL OCOMO("Selecting the AA.ARR.PAYMENT.SCHEDULE WITH BASE.DATE EQ ''")
    SEL.STMT = "SELECT FBNK.AA.ARR.PAYMENT.SCHEDULE WITH BASE.DATE EQ ''"
    CALL EB.READLIST(SEL.STMT,ID.LIST,'',ID.SELECTED,ERR)

    LOOP
        REMOVE Y.ID FROM ID.LIST SETTING YID.POS
    WHILE Y.ID:YID.POS

        CALL OCOMO("'Processing the record : ":Y.ID)
        CALL F.READ(FN.ARR.PS, Y.ID, Y.ARR.REC, F.ARR.PS, ERR)

        IF Y.ARR.REC<AA.PS.BASE.DATE> EQ "" THEN
            ARR.ID = FIELD(Y.ID,'-',1)        ;*Get the arrangement ID.

            IF ARR.ID THEN

                CALL AA.GET.BASE.DATE.TYPE(ARR.ID, "", "BASE", BASE.DATE)     ;* Get the base date

                IF BASE.DATE EQ "" THEN
                    CALL F.READ(FN.AA.ACC, ARR.ID, AA.ACC.REC, F.AA.ACC, ERR)
                    BASE.DATE = AA.ACC.REC<AA.AD.START.DATE>          ;*If not get it from AA.ACCOUNT.DETAILS
                END

                Y.ARR.REC<AA.PS.BASE.DATE> = BASE.DATE
                CALL F.WRITE(FN.ARR.PS,Y.ID, Y.ARR.REC)
            END

        END
        REC.CNT +=1
        IF MOD(REC.CNT,500) EQ 0 THEN ;*AUTO R22 CODE CONVERSION
            CALL JOURNAL.UPDATE("")
        END


    REPEAT

RETURN

PROCESS.UNAUTH:

* Select the BASE.DATE eq NULL reocrds from AA.ARR.PAYMENT.SCHEDULE$NAU

    ID.LIST = ""
    ID.SELECTED = ""
    ERR = ""

    CALL OCOMO("Selecting the AA.ARR.PAYMENT.SCHEDULE WITH BASE.DATE EQ ''")
    SEL.STMT = "SELECT FBNK.AA.ARR.PAYMENT.SCHEDULE$NAU WITH BASE.DATE EQ ''"
    CALL EB.READLIST(SEL.STMT,ID.LIST,'',ID.SELECTED,ERR)

    LOOP
        REMOVE Y.ID FROM ID.LIST SETTING YID.POS
    WHILE Y.ID:YID.POS
        CALL OCOMO('Processing the record : ':Y.ID)

        Y.ARR.REC = ""
        CALL F.READ(FN.ARR.PS$NAU, Y.ID, Y.ARR.REC, F.ARR.PS$NAU, ERR)

        IF Y.ARR.REC<AA.PS.BASE.DATE> EQ "" THEN
            ARR.ID = FIELD(Y.ID,'-',1)        ;* Get the arrangement ID.

            IF ARR.ID THEN

                CALL AA.GET.BASE.DATE.TYPE(ARR.ID, "", "BASE", BASE.DATE)     ;*Get the base date

                IF BASE.DATE EQ "" THEN
                    CALL F.READ(FN.AA.ACC, ARR.ID, AA.ACC.REC, F.AA.ACC, ERR)
                    BASE.DATE = AA.ACC.REC<AA.AD.START.DATE>          ;*If not get it from AA.ACCOUNT.DETAILS
                END

                Y.ARR.REC<AA.PS.BASE.DATE> = BASE.DATE
                CALL F.WRITE(FN.ARR.PS$NAU, Y.ID, Y.ARR.REC)
            END
        END

        REC.CNT +=1
        IF MOD(REC.CNT,500) EQ 0 THEN ;*AUTO R22 CODE CONVERSION
            CALL JOURNAL.UPDATE("")
        END
    REPEAT
RETURN

END
