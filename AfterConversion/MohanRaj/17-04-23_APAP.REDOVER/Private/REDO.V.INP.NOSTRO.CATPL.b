* @ValidationCode : MjotMTUyOTYzMDM2OTpDcDEyNTI6MTY4MTcyOTU4ODE5OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:36:28
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
SUBROUTINE REDO.V.INP.NOSTRO.CATPL
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as INPUT routine in TELLER CHEQUE's VERSIONS
*
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date            who             Reference            Description
*   ~~~~            ~~~             ~~~~~~~~~            ~~~~~~~~~~~
*   08-MAR-2012     NAVA V.       PACS00172913           Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
*
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.MANAGER.CHQ.PARAM
*
    GOSUB INIT
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*---------------------------------------------------------------------------
*
* ======
PROCESS:
* ======
*
*
    IF Y.FLG NE "" AND Y.FLG.CAT EQ "" THEN
        AF = TT.TE.LOCAL.REF
        AV = POS.L.TT.NOS.ACCT
        ETEXT  = "EB-PARAMETER.RECORD.&.MISSING":@FM:Y.ACCOUNT:@VM:FN.REDO.MANAGER.CHQ.PARAM
        CALL STORE.END.ERROR
        ETEXT  = ""
    END
*
RETURN
*
* ===
INIT:
* ===
*
    PROCESS.GOAHEAD      = 1
*
    FN.REDO.MANAGER.CHQ.PARAM = 'F.REDO.MANAGER.CHQ.PARAM'
    F.REDO.MANAGER.CHQ.PARAM  = ''
    CALL OPF(FN.REDO.MANAGER.CHQ.PARAM,F.REDO.MANAGER.CHQ.PARAM)
*
    LRF.APP = "TELLER"
    LRF.FIELD = "L.TT.TAX.CODE":@VM:"L.TT.WV.TAX":@VM:"L.FT.NOSTRO.ACC"
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)
    POS.L.TT.TAX.CODE   = LRF.POS<1,1>
    POS.L.TT.WV.TAX     = LRF.POS<1,2>
    POS.L.TT.NOS.ACCT   = LRF.POS<1,3>
*
    Y.WV.TAX.CODE       = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.TAX.CODE>
    Y.WV.TAX.YES.NO     = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.WV.TAX>
    Y.L.TT.NOSTRO.AC    = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.NOS.ACCT>
*
    CHANGE @SM TO @FM IN Y.WV.TAX.CODE
    CHANGE @SM TO @FM IN Y.WV.TAX.YES.NO
*
    Y.PARAM.ID = 'SYSTEM'
    Y.ACCOUNT  = Y.L.TT.NOSTRO.AC
    WCATEGORY  = ""
    Y.FLG      = ""
    Y.FLG.CAT  = ""
*
RETURN

* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP.CNT  = 1
    MAX.LOOPS = 3
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1
*
                IF Y.L.TT.NOSTRO.AC EQ "" THEN
                    PROCESS.GOAHEAD = ""
                END
*
            CASE LOOP.CNT EQ 2
*
                Y.NY.CNT = ""
                Y.NY.CNT = DCOUNT(Y.WV.TAX.YES.NO,@FM)
                FOR I.VAR=1 TO Y.NY.CNT ;*R22 Auto code conversion-START
                    IF Y.WV.TAX.YES.NO<I.VAR> EQ "YES" THEN
                        Y.FLG = 1
                    END
                NEXT I.VAR ;*R22 Auto code conversion-END
*
            CASE LOOP.CNT EQ 3
*
                CALL CACHE.READ(FN.REDO.MANAGER.CHQ.PARAM,Y.PARAM.ID,R.REDO.MANAGER.CHQ.PARAM,PARAM.ERR)
                Y.ACCOUNT.ALL = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ACCOUNT>
                Y.CATEGORY    = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.CATEGORY>
                LOCATE Y.ACCOUNT IN Y.ACCOUNT.ALL<1,1> SETTING ACCT.POS THEN
                    Y.FLG.CAT = 1
                END
*
        END CASE
        LOOP.CNT +=1
*
    REPEAT
*
RETURN
*
END
