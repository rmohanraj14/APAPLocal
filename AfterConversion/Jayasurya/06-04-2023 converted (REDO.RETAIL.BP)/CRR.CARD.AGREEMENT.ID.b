* @ValidationCode : MjotNjQyNzQ4MjUwOkNwMTI1MjoxNjgwNzc5MTE3MTEzOklUU1NCTkc6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAyMTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 16:35:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSSBNG
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202108.0
$PACKAGE APAP.REDORETAIL
SUBROUTINE CRR.CARD.AGREEMENT.ID
*------------------------------------------------------------------------------------------
*DESCRIPTION
* .ID routine to validate the ID for the template CRR.CARD.AGREEMENT
*------------------------------------------------------------------------------------------
*APPLICATION
* CRR.CARD.AGREEMENT as .ID routine
*------------------------------------------------------------------------------------------
*
* Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*
*----------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : Temenos Application Management
* PROGRAM NAME : CRR.CARD.AGREEMENT.ID
*----------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO         REFERENCE         DESCRIPTION
*08.07.2010      Manju.G     ODR-2009-12-0264    INITIAL CREATION
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*06-04-2023           CONVERSION TOOL                AUTO R22 CODE CONVERSION                 NO CHANGES
*06-04-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES
*
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CARD.TYPE

    GOSUB INIT
    GOSUB PROCESS
RETURN

INIT:
*--------
    FN.CARD.TYPE = 'F.CARD.TYPE'
    F.CARD.TYPE = ''
    CALL OPF(FN.CARD.TYPE,F.CARD.TYPE)
RETURN

PROCESS:
*---------
    Y.ID = FIELD(ID.NEW,'.',1)
    CALL F.READ(FN.CARD.TYPE,Y.ID,R.CARD.TYPE,F.CARD.TYPE,ERR.CARD)
    IF R.CARD.TYPE EQ '' THEN
        E = 'EB-CRR.INVALID.AGREE.ID'
        CALL STORE.END.ERROR
        GOSUB END.PROGRAM
    END
    Y.NO = FIELD(ID.NEW,'.',2)
    Y.COUNT = LEN(Y.NO)
    IF NUM(Y.NO) ELSE
        E = 'EB-CRR.INVALID.LENGTH'
        CALL STORE.END.ERROR
        GOSUB END.PROGRAM
    END

    IF Y.COUNT NE '2' THEN
        E = 'EB-CRR.INVALID.LENGTH'
        CALL STORE.END.ERROR
        GOSUB END.PROGRAM
    END


RETURN
*--------------------------------------------------------------------------------
END.PROGRAM:
*-------------
END
*---------------------------------------------------------------------------------
