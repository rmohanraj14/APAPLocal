* @ValidationCode : MjotMTU0Mjg0MzE0NDpDcDEyNTI6MTY4MTg4NzQxNDY2Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:26:54
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
SUBROUTINE REDO.V.VAL.COLL.CREDITO

*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.COLL.CREDITO
* Attached as     : ROUTINE
* Primary Purpose : VERIFY IF THE USER SET THE FIELD CREDIT NUMBER
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De la Rosa - TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM ,FM TO @FM,SM TO @SM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.FC.PROD.COLL.POLICY
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS
*
RETURN
*
*-----------------------------------------------------------------------------------
PROCESS:
*======
*READ THE FIELD CREDIT NUMBER
*
    VAR.CRED = R.NEW(COLL.LOCAL.REF)<1,WPOSCRED>
    VAR.LEN = LEN(TRIM(VAR.CRED))
    IF LEN(TRIM(VAR.CRED)) EQ 0 THEN
        GOSUB VERIFY.COLL.RIGHT
        RETURN
    END
* PACS00312875 - S
    AA.ID = VAR.CRED
    GOSUB READ.AA.RECORD
* PACS00312875 - E
*
RETURN
*----------------------------------------------------------------------------
*
INITIALISE:
*=========

    FN.COLLATERAL   = 'F.COLLATERAL'
    F.COLLATERAL    = ''
    R.COLLATERAL    = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''

    FN.REDO.FC.PROD.COLL.POLICY = 'F.REDO.FC.PROD.COLL.POLICY'
    F.REDO.FC.PROD.COLL.POLICY = ''
    R.REDO.FC.PROD.COLL.POLICY = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    FN.COLLATERAL.RIGHT = 'F.COLLATERAL.RIGHT'
    F.COLLATERAL.RIGHT = ''
    R.COLLATERAL.RIGHT = ''

*Set the local fild for read
    WCAMPO     = "L.AC.LK.COL.ID"
    Y.COLL.CODE = R.NEW(COLL.COLLATERAL.CODE)
    Y.COLL.TYPE = R.NEW(COLL.COLLATERAL.TYPE)

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOSCRED  = YPOS<1,1>
    COL.COD.POS = ''
    COL.COD.TP = ''
*READ THE FIELD CREDIT NUMBER
    VAR.CRED = R.NEW(COLL.LOCAL.REF)<1,WPOSCRED>
    AA.ID    = ''     ;* PACS00312875 - S/E
*
RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.REDO.FC.PROD.COLL.POLICY,F.REDO.FC.PROD.COLL.POLICY)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT)
RETURN
*------------
*------------------------
SEND.ERROR:
*=========
    AF = COLL.LOCAL.REF
    AV = WPOSCRED
    AS = Y.VAR
    ETEXT = 'EB-FC-ERROR.TYPE.LOAN':@FM:Y.AA.ID      ;* PACS00312875 - S/E
    CALL STORE.END.ERROR
RETURN
*------------------------
READ.AA.RECORD:
*------------------------
*
    Y.AA.NUM = DCOUNT(AA.ID,@SM)
    Y.VAR = 1
    LOOP
    WHILE Y.VAR LE Y.AA.NUM
        Y.AA.ID = FIELD(AA.ID,@SM,Y.VAR)
*
        GOSUB GET.AA.ACCT         ;* PACS00312875 - S/E
*
        IF Y.ERR THEN
            AF = COLL.LOCAL.REF
            AV = WPOSCRED
            AS = Y.VAR
            ETEXT = 'EB-FC-READ.ERROR.REC':@FM:Y.AA.ID
            CALL STORE.END.ERROR
            RETURN
        END
*
        GOSUB VAL.AA.PRODUCT      ;* PACS00307565 - S/E
*
        Y.VAR += 1
    REPEAT
*
RETURN
*
*===================
VAL.AA.PRODUCT:
*===================
*
    IF Y.ERR THEN
        RETURN
    END
*
    Y.PRODUCT = '' ; Y.PRODUCT = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
    CALL F.READ(FN.REDO.FC.PROD.COLL.POLICY,Y.PRODUCT,R.REDO.FC.PROD.COLL.POLICY,F.REDO.FC.PROD.COLL.POLICY,Y.ERR)
*
    IF Y.ERR THEN
        AF = COLL.LOCAL.REF
        AV = WPOSCRED
        AS = Y.VAR
        ETEXT = 'EB-FC-READ.ERROR':@FM:FN.REDO.FC.PROD.COLL.POLICY
        CALL STORE.END.ERROR
    END
    LOCATE Y.COLL.CODE IN R.REDO.FC.PROD.COLL.POLICY<REDO.CPL.COLLATERAL.CODE,1> SETTING COL.COD.POS THEN
        LOCATE Y.COLL.TYPE IN R.REDO.FC.PROD.COLL.POLICY<REDO.CPL.COLLATERAL.TYPE,COL.COD.POS,1> SETTING COL.COD.TP ELSE
            GOSUB SEND.ERROR
        END
*
    END ELSE
        GOSUB SEND.ERROR
    END
*
RETURN
*
*------------------------
SEND.OVERRIDE:
*------------------------
    TEXT = "COLL.ASIG.CRED"
    M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
    CALL STORE.OVERRIDE(M.CONT)

RETURN
*===================
VERIFY.COLL.RIGHT:
*===================

    COLL.RIGHT.ID = FIELD(ID.NEW,".",1,2)
    CALL F.READ(FN.COLLATERAL.RIGHT,COLL.RIGHT.ID,R.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT,YERR)
    IF NOT(R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE> ) THEN
        GOSUB SEND.OVERRIDE
    END
RETURN
*
*===================
GET.AA.ACCT:
*===================
*
    IF Y.AA.ID[1,2] EQ "AA" THEN
        GOSUB READ.AA.ARR
    END
*
    IF Y.AA.ID[1,2] NE "AA" THEN
        Y.ERR = '' ; R.ACCOUNT = ''
        CALL F.READ(FN.ACCOUNT,Y.AA.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
        Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        GOSUB READ.AA.ARR
    END
*
RETURN
*
*===================
READ.AA.ARR:
*===================
*
    Y.ERR = '' ; R.AA.ARRANGEMENT = ''
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.ERR)
*
RETURN
*
END
