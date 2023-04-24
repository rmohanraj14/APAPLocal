* @ValidationCode : MjotMTQ0NzQxMjU5NTpDcDEyNTI6MTY4MjMxNDkyOTUwNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Apr 2023 11:12:09
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
*24-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.GET.CAJERO.USER.RT
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER.ID

*--DEBUG

    Y.INP.USER.ID  = COMI
    Y.INP.USER.ID = Y.INP.USER.ID<1,1>
    Y.INP.USER.ID = FIELD(Y.INP.USER.ID, "_",2)

*--Y.INP.USER.ID  = 'A.13498'

    GOSUB INIT
    GOSUB PROCESS

    COMI = Y.ID.CAJERO

RETURN

*---------------
INIT:
*---------------

    Y.ID.CAJERO =''
    FN.TELLER.ID = 'F.TELLER.ID'
    FV.TELLER.ID  = ""
    R.TELLER.ID = ""
    TELLER.ID_ERR = ""
    CALL OPF(FN.TELLER.ID,FV.TELLER.ID)

RETURN

*---------------
PROCESS:
*---------------
*--DEBUG

    SEL.CMD = 'SELECT ' : FN.TELLER.ID : ' WITH USER LIKE "' : Y.INP.USER.ID : '"'
    CALL EB.READLIST(SEL.CMD, SEL.LIST,"", NO.OF.REC, SEL.ERR)

    LOOP
        REMOVE Y.TELLER.ID FROM SEL.LIST SETTING RTE.POS
    WHILE Y.TELLER.ID DO
        IF NO.OF.REC EQ 1 THEN
            Y.ID.CAJERO = Y.TELLER.ID
            RETURN
        END ELSE
            CALL F.READ(FN.TELLER.ID,Y.TELLER.ID,R.TELLER.ID,FV.TELLER.ID,TELLER.ID_ERR)

            Y.ID.CAJERO = Y.TELLER.ID
            IF R.TELLER.ID<TT.TID.RECORD.STATUS> EQ 'OPEN'  THEN
                RETURN
            END
        END

    REPEAT

RETURN
END
