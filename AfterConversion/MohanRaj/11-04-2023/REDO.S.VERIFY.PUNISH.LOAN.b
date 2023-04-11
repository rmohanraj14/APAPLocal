* @ValidationCode : MjotMTA3MzU5ODg2NDpDcDEyNTI6MTY4MTIxNTQ2NDczOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:47:44
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.VERIFY.PUNISH.LOAN(Y.RESPONSE)
*--------------------------------------------------------------------------
* Developer    : Mauricio Sthandier (msthandier@temenos.com)
*                TAM Latin America
* Client       : Asociacion Popular de Ahorro & Prestamo (APAP)
* Date         : 01.01.2015
* Description  : Routine for updating CONCAT of succesful/rejected
* Type         : Batch Routine
* Attached to  : BATCH > BNK/REDO.VP.PUNISHED.UPLOAD
* Dependencies : NA
*--------------------------------------------------------------------------
* Modification History:
*
* Version   Date           Who            Reference         Description
* 1.0       01.06.2015     msthandier     -                 Initial Version
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------

* <region name="INSERTS">
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.VP.PUNISHED.UPLOAD
* </region>


    IF APPLICATION EQ "DM.SERVICE.CONTROL" THEN
        RETURN
    END
* Get AA ID
    Y.PART.1 = FIELD(Y.RESPONSE,',',1)
    Y.ACT.ID = FIELD(Y.PART.1,'/',1)
    Y.PART.2 = FIELD(Y.RESPONSE,',',2)
    Y.AA.ID = FIELD(Y.PART.2,'=',2)
    CHANGE '<requests><request>' TO '' IN Y.ACT.ID

* Check status in response
    FINDSTR '/-1' IN Y.PART.1 SETTING Y.POS THEN
        Y.ACT.STATUS = 'N'
        Y.ACT.MSG = Y.AA.ID
        Y.AA.ID = R.NEW(1)
    END ELSE
        FINDSTR '/1' IN Y.PART.1 SETTING Y.POS THEN
            Y.ACT.STATUS = 'Y'
            Y.ACT.MSG = ''
        END ELSE
            Y.ACT.STATUS = 'N'
            Y.ACT.MSG = Y.AA.ID
            Y.AA.ID = R.NEW(1)
        END
    END

* Update LIVE file
    FN.REDO.VP.PUNISHED.UPLOAD = 'F.REDO.VP.PUNISHED.UPLOAD'
    F.REDO.VP.PUNISHED.UPLOAD = ''
    CALL OPF(FN.REDO.VP.PUNISHED.UPLOAD,F.REDO.VP.PUNISHED.UPLOAD)
    CALL F.READ(FN.REDO.VP.PUNISHED.UPLOAD,Y.AA.ID,R.RPU,F.REDO.VP.PUNISHED.UPLOAD,Y.RPU.ERR)
    R.RPU<PUN.UPL.ACTIVITY.STATUS,-1> = Y.ACT.STATUS
    R.RPU<PUN.UPL.ACTIVITY.MESSAGE,-1> = Y.ACT.MSG
    IF R.RPU<PUN.UPL.OVERALL.STATUS> NE 'N' THEN
        R.RPU<PUN.UPL.OVERALL.STATUS> = Y.ACT.STATUS
    END
    CALL F.WRITE(FN.REDO.VP.PUNISHED.UPLOAD,Y.AA.ID,R.RPU)
RETURN
END
