-- see ERD as picture

-- Relational Schema
/*
PLAYER ( Username )
PRIMARY KEY ( Username )

TURN ( TurnId, PlayersSelection, AiSelection, Username )
PRIMARY KEY ( TurnId, Username )
FOREIGN KEY ( Username ) REFERENCES PLAYER
*/

-- DDL Data Definition Language

GO
USE test

GO

IF OBJECT_ID('PLAYER') IS NOT NULL
DROP TABLE PLAYER;

IF OBJECT_ID('TURN') IS NOT NULL
DROP TABLE TURN;

GO

CREATE TABLE PLAYER (
    Username    NVARCHAR(50) NOT NULL
,   PRIMARY KEY ( Username )
);

CREATE TABLE TURN (
    TurnId      DATETIME NOT NULL
,   Username    NVARCHAR(50) NOT NULL
,   PlayersSelection    NVARCHAR(10) NOT NULL
,   AiSelection     NVARCHAR(10) NOT NULL
,   PRIMARY KEY ( TurnId, Username )
,   FOREIGN KEY ( Username ) REFERENCES PLAYER
);