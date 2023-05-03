* @ValidationCode : MjotNjQwMDM0NDg1OkNwMTI1MjoxNjgxNzMzNjg1NzU3OklUU1M6LTE6LTE6LTU3OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -57
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ARC.FT.CALC.COMM
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION :   This routine will be executed at COB for STO purpose
*------------------------------------------------------------------------------------------
*
* COMPANY NAME : APAP
* DEVELOPED BY : IVAN ROMAN
* PROGRAM NAME : REDO.ARC.FT.CALC.COMM
*
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*       DATE             WHO                REFERENCE         DESCRIPTION
*       17-01-2012       IVAN ROMAN
*
* 12-APR-2023     Conversion tool   R22 Auto conversion   	VM to @VM, = to EQ
* 12-APR-2023      Harishvikram C   Manual R22 conversion      No changes
* -----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
*
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.FT.TXN.TYPE.CONDITION
*

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*
* ======
PROCESS:
* ======
*
    R.NEW(FT.CHARGE.CODE)     = ""
    R.NEW(FT.COMMISSION.CODE) = ""
    WCHRG.AMT                 = 0
*
    CALL FT.DEF.COMM.CHG(R.COMM.DEFAULT,R.CHARGE.DEFAULT,R.TAX.DEFAULT,COMM.CCY,INPUT.AMT,CHARGE.ACCT.CCY,OTHER.CCY,TOTAL.FOR.COMM.CHG,TOTAL.LOC.COMM.CHG,CURR.NO)

    W.COMM.CODE     = RAISE(R.COMM.DEFAULT<1>)
    W.COMM.AMT      = RAISE(R.COMM.DEFAULT<5>)

    Y.CONT.FLAG = 1

    LOOP
        REMOVE WCOMM.CODE FROM W.COMM.CODE SETTING POS.ERR
    WHILE WCOMM.CODE:POS.ERR
        REMOVE WCOMM.AMT FROM W.COMM.AMT SETTING POS.AMT
        IF Y.FT.COMM.CODE NE 'WAIVE' THEN
            WCHRG.AMT += WCOMM.AMT
        END
        LOCATE WCOMM.CODE IN Y.COMM.CODE<1> SETTING COMM.POS THEN
            Y.COMM.AMT<COMM.POS> = WCOMM.AMT
            Y.WV.COMM<COMM.POS>  = "NO"
            IF Y.FT.COMM.CODE EQ 'WAIVE' THEN
                Y.WV.COMM<COMM.POS>  = "YES"
            END
        END ELSE

            LOCATE WCOMM.CODE IN Y.TAX.CODE<1> SETTING TAX.POS THEN
                GOSUB CHECK.WAIVE
            END
        END
    REPEAT
*
    R.NEW(FT.CHARGE.CODE)     = "WAIVE"
    R.NEW(FT.COMMISSION.CODE) = "WAIVE"
*
    R.NEW(FT.LOCAL.REF)<1,L.TT.COMM.CODE.POS>  = LOWER(LOWER(Y.COMM.CODE))
    R.NEW(FT.LOCAL.REF)<1,L.TT.TAX.CODE.POS>   = LOWER(LOWER(Y.TAX.CODE))
    R.NEW(FT.LOCAL.REF)<1,L.TT.COMM.AMT.POS>   = LOWER(LOWER(Y.COMM.AMT))
    R.NEW(FT.LOCAL.REF)<1,L.TT.TAX.AMT.POS>    = LOWER(LOWER(Y.TAX.AMT))
    R.NEW(FT.LOCAL.REF)<1,L.TT.WV.COMM.POS>    = LOWER(LOWER(Y.WV.COMM))
    R.NEW(FT.LOCAL.REF)<1,L.TT.WV.TAX.POS>     = LOWER(LOWER(Y.WV.TAX))
    R.NEW(FT.LOCAL.REF)<1,L.TT.WV.TAX.AMT.POS> = 0
*
    IF Y.FT.COMM.CODE EQ "DEBIT PLUS CHARGES" OR Y.FT.COMM.CODE EQ "" THEN
        R.NEW(FT.LOCAL.REF)<1,L.TT.TRANS.AMT.POS>  = Y.AMOUNT + WCHRG.AMT
    END ELSE
        R.NEW(FT.LOCAL.REF)<1,L.TT.TRANS.AMT.POS>  = Y.AMOUNT
    END
*
RETURN
*
* =========
OPEN.FILES:
* =========
*
RETURN
*
*==========
CHECK.WAIVE:
*==========
    Y.TAX.AMT<TAX.POS> = WCOMM.AMT
    Y.WV.TAX<TAX.POS>  = "NO"
    IF Y.FT.COMM.CODE EQ 'WAIVE' THEN
        Y.WV.TAX<TAX.POS>  = "YES"
    END
RETURN
* =========
INITIALISE:
* =========
*
    Y.AMOUNT  =  R.NEW(FT.DEBIT.AMOUNT)
    IF Y.AMOUNT EQ '' THEN
        Y.AMOUNT =  R.NEW(FT.CREDIT.AMOUNT)
    END

    LOOP.CNT        = 1
    MAX.LOOPS       = 1
    PROCESS.GOAHEAD = 1

    WCAMPO  = "L.TT.COMM.CODE" : @VM : "L.TT.TAX.CODE"
    WCAMPO := @VM : "L.TT.COMM.AMT" : @VM : "L.TT.TAX.AMT"
    WCAMPO := @VM : "L.TT.WV.COMM" : @VM : "L.TT.WV.TAX"
    WCAMPO := @VM : "L.TT.WV.TAX.AMT" : @VM : "L.TT.TRANS.AMT"
    WCAMPO := @VM : "L.FT.COMM.CODE"
    YPOS=''
    CALL MULTI.GET.LOC.REF("FUNDS.TRANSFER",WCAMPO,YPOS)

    L.TT.COMM.CODE.POS  = YPOS<1,1>
    L.TT.TAX.CODE.POS   = YPOS<1,2>
    L.TT.COMM.AMT.POS   = YPOS<1,3>
    L.TT.TAX.AMT.POS    = YPOS<1,4>
    L.TT.WV.COMM.POS    = YPOS<1,5>
    L.TT.WV.TAX.POS     = YPOS<1,6>
    L.TT.WV.TAX.AMT.POS = YPOS<1,7>
    L.TT.TRANS.AMT.POS  = YPOS<1,8>
    Y.L.FT.COMM.POS     = YPOS<1,9>

** INPUT

    IF AF EQ FT.DEBIT.AMOUNT THEN
        POS.CCY   = FT.DEBIT.CURRENCY
        POS.ACT   = FT.DEBIT.ACCT.NO
        OTH.CCY   = FT.CREDIT.CURRENCY
    END ELSE
        POS.CCY = FT.CREDIT.CURRENCY
        POS.ACT = FT.CREDIT.ACCT.NO
        OTH.CCY = FT.DEBIT.CURRENCY
    END
*
    IF R.NEW(FT.COMMISSION.CODE) EQ "CREDIT LESS CHARGES" THEN
        CHARGE.ACCT.CCY = R.NEW(FT.CREDIT.CURRENCY)
    END ELSE
        CHARGE.ACCT.CCY = R.NEW(FT.DEBIT.CURRENCY)
    END
*
    INPUT.AMT       = Y.AMOUNT
    COMM.CCY        = R.NEW(POS.CCY)
    OTHER.CCY       = R.NEW(OTH.CCY)
    CURR.NO         = R.NEW(FT.CURR.NO)

** OUTPUT

    R.COMM.DEFAULT     = ''
    R.CHARGE.DEFAULT   = ''
    R.TAX.DEFAULT      = ''
    TOTAL.FOR.COMM.CHG = ''
    TOTAL.LOC.COMM.CHG = ''

** RESTORE DATA TO VERSION

    Y.COMM.CODE    = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.COMM.CODE.POS>))
    Y.TAX.CODE     = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.TAX.CODE.POS>))
    Y.COMM.AMT     = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.COMM.AMT.POS>))
    Y.TAX.AMT      = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.TAX.AMT.POS>))
    Y.WV.COMM      = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.WV.COMM.POS>))
    Y.WV.TAX       = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.WV.TAX.POS>))
    Y.WV.TAX.AMT   = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.WV.TAX.AMT.POS>))
    Y.TRANS.AMT    = RAISE(RAISE(R.NEW(FT.LOCAL.REF)<1,L.TT.TRANS.AMT.POS>))
    Y.FT.COMM.CODE = R.NEW(FT.LOCAL.REF)<1,Y.L.FT.COMM.POS>
*
RETURN
*
* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
                IF (Y.COMM.CODE EQ "" AND Y.TAX.CODE EQ "") OR MESSAGE EQ "VAL" THEN
                    PROCESS.GOAHEAD = ""
                END

        END CASE

        LOOP.CNT +=1
    REPEAT
*
RETURN
*
END
