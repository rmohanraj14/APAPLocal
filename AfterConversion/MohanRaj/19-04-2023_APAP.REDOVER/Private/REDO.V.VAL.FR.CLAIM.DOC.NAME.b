* @ValidationCode : MjoxMzEwMjgwODAzOkNwMTI1MjoxNjgxODkwNzQ3MDU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:22:27
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
SUBROUTINE REDO.V.VAL.FR.CLAIM.DOC.NAME
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.VAL.FR.CLAIM.DOC.NAME
*--------------------------------------------------------------------------------
* Description: This Validation routine is to populate the document that
* required for the request from REDO.SLA.PARAM
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE         WHO         REFERENCE         DESCRIPTION
* 24-May-2011   Pradeep S   PACS00071941      INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM,CONVERT TO CHANGE
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.REDO.FRONT.CLAIMS
    $INSERT I_F.REDO.SLA.PARAM

    GOSUB PRE.PROCESS
RETURN


PRE.PROCESS:
*************
    IF COMI THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END ELSE
        R.NEW(FR.CL.DOC.NAME) = ''
        R.NEW(FR.CL.DOC.REV) = ''
        ETEXT = 'EB-MAND.INP'
        CALL STORE.END.ERROR
    END

RETURN

OPEN.FILES:
************

    FN.SLA = 'F.REDO.SLA.PARAM'
    F.SLA = ''
    CALL OPF(FN.SLA,F.SLA)

    Y.PRDT.TYPE = R.NEW(FR.CL.PRODUCT.TYPE)

    IF Y.PRDT.TYPE THEN
        BEGIN CASE

            CASE Y.PRDT.TYPE EQ 'TARJETA.DE.CREDITO'
                T(FR.CL.ACCOUNT.ID)<3> = 'NOINPUT'
                N(FR.CL.CARD.NO) := '.1'
                R.NEW(FR.CL.ACCOUNT.ID) = ''
            CASE Y.PRDT.TYPE EQ 'OTROS'
                R.NEW(FR.CL.ACCOUNT.ID) = ''
                R.NEW(FR.CL.CARD.NO) = ''
            CASE 1
                T(FR.CL.CARD.NO)<3> = 'NOINPUT'
                N(FR.CL.ACCOUNT.ID) := '.1'
                R.NEW(FR.CL.CARD.NO) = ''
        END CASE

    END

RETURN

PROCESS:
*********

    Y.TYPE = R.NEW(FR.CL.TYPE)
    Y.PDT.TYPE = R.NEW(FR.CL.PRODUCT.TYPE)
    Y.SLA.ID = Y.TYPE:'-':Y.PDT.TYPE
    R.NEW(FR.CL.SLA.ID) = Y.SLA.ID
    R.SLA = ''
    CALL CACHE.READ(FN.SLA,Y.SLA.ID,R.SLA,SLA.ERR)

    IF R.SLA THEN
        Y.CLAIM.TYPES = R.SLA<SLA.DESCRIPTION>
        LOCATE COMI IN Y.CLAIM.TYPES<1,1> SETTING POS THEN
            R.NEW(FR.CL.RISK.LEVEL) = R.SLA<SLA.RISK.LEVEL,POS>
            R.NEW(FR.CL.SUPPORT.GROUP) = R.SLA<SLA.SUPPORT.GROUP,POS>
            GOSUB CHECK.CHANNEL
            GOSUB CHK.DOC
        END
    END

RETURN

CHECK.CHANNEL:
**************

    Y.SLA.CHANNEL = R.SLA<SLA.START.CHANNEL,POS>
    CHANGE @SM TO @FM IN Y.SLA.CHANNEL
    Y.CHANNEL = R.NEW(FR.CL.OPENING.CHANNEL)

    Y.SLA.CHANNEL = FIELDS(Y.SLA.CHANNEL,'-',1,1)

    Y.ERR.FLAG = @FALSE
    LOCATE Y.CHANNEL IN Y.SLA.CHANNEL SETTING CHANNEL.POS ELSE
        Y.ERR.FLAG = @TRUE
        ETEXT = 'EB-REQ.SLA.CHANNEL'
        CALL STORE.END.ERROR
    END

RETURN

CHK.DOC:
*********
    IF NOT(Y.ERR.FLAG) THEN
        Y.DOC.REQ = R.SLA<SLA.DOC.REQUIRE,POS>
        CHANGE @SM TO @VM IN Y.DOC.REQ ;*R22 Auto code conversion
        Y.DOC.REV.BK = R.NEW(FR.CL.DOC.REV)
        R.NEW(FR.CL.DOC.REV) = ''
        R.NEW(FR.CL.DOC.NAME) = Y.DOC.REQ
        Y.DOC.CNT = DCOUNT(Y.DOC.REQ,@VM)

        Y.DOC.REV.INC = 1
        LOOP
        WHILE Y.DOC.REV.INC LE Y.DOC.CNT
            R.NEW(FR.CL.DOC.REV)<1,Y.DOC.REV.INC>  = Y.DOC.REV.BK<1,Y.DOC.REV.INC>
            Y.DOC.REV.INC += 1
        REPEAT

    END

RETURN

END
