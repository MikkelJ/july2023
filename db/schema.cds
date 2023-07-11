using {
    cuid,
    temporal,
    managed
} from '@sap/cds/common';

namespace golf;

context location {
    entity Club : cuid {
        name               : String;
        address            : String;

        courses            : Association to many location.Course
                                 on courses.club = $self;
        trainingFacilities : Composition of location.TrainingFacilities
                                 on trainingFacilities.club = $self;
    }

    entity TrainingFacilities : cuid {
        name : String;
        type : String enum {
            DrivingRange;
            PracticeGreen;
            PracticeBunker;
        };

        club : Association to one location.Club;
    }

    entity Course : cuid {
        name         : String;
        description  : String;
        noOfHoles    : Integer;
        difficulty   : Integer; // 0 = pro to 5 = beginner
        courseRating : Integer; //
        slopeRating  : Integer; //

        club         : Association to one location.Club;
        holes        : Composition of many location.Hole
                           on holes.course = $self;
    }

    entity Hole {
        key ID        : Integer;
            direction : String; // Out (away from club house) or In (towards club house)

        key course    : Association to one location.Course;
            variants  : Composition of many location.Hole_Variant
                            on variants.hole = $self;
    }

    entity Hole_Variant : cuid, temporal { // temportal https://cap.cloud.sap/docs/guides/temporal-data#time-travel-queries
        BoxTeeType     : Integer; // 0 = Pro, 1 = Mens, 2 = Ladies,  3 = Junior/Forward Tee the lower number, the greater distance from hole
        BoxTeeTypeText : String; //localized text
        distanceToHole : Decimal;
        color          : String;
        virtual active : Boolean;
        par            : Integer;
        hole           : Association to one location.Hole;
    }
}


entity Player : managed {
    key nationalID   : String;
        firstName    : String;
        lastName     : String;
        handicap     : Decimal;
        hasGreenCard : Boolean;
        dateOfBirth  : Date;
        gender       : String enum {
            Male;
            Female;
        };

        scoreCards   : Composition of many game.ScoreCard
                           on scoreCards.player = $self;
}


context game {
    entity Tournament : cuid, managed {
        name        : String;
        description : String;
        fromDate    : Date;
        toDate      : Date;
    // prizes etc.
    }

    entity Round : cuid, managed {
        startDateTime      : DateTime;
        endDateTime        : DateTime;

        scoreCards         : Composition of many game.ScoreCard
                                 on scoreCards.round = $self;
        course             : Association to one location.Course;
        currentHole        : Association to one location.Hole; // Change to be actual hole variant and not game.hole;
        nextPlayer : Association to one Player; // calculated based on distance to hole on currentHole
    }

    entity ScoreCard : cuid, managed {
        handicap           : Decimal; // Handicap at beginning of round
        submitted          : Boolean;
        virtual totalScore : Integer;
        round              : Association to one Round;
        player             : Association to one Player;
        holes              : Composition of many game.Hole
                                 on holes.scoreCard = $self;
    }

    entity Hole : cuid, managed {
        scoreCard               : Association to one ScoreCard;
        // Association to a specific hole variant
        virtual recordedStrokes : Integer; // Aggregation / sum of total strokes
        handicap                : Integer;
        virtual maxStrokes      : Integer; // calculated maximum number of strokes using hcpIndex of hole and player handicap - max is double Bogey + Handicap Strokes
        virtual score           : Integer; // assert from -{par} to (+{par} + handicap strokes) eg. albatross, birdie, boogie etc.
        virtual scoreText       : String enum {
            Condor; //-4
            Albatross; //-3
            Eagle; //-2
            Birdie; //-1
            Par; //0
            Bogey; //+1
        };

        strokes                 : Composition of many game.Stroke
                                      on strokes.hole = $self;
    }

    entity Stroke : cuid, managed {
        distance                        : Decimal; // Length of stroke
        distanceToHole                  : Decimal;
        virtual effectiveStrokeDistance : Decimal; // The effective distance, the distance of the stroke might be 200 meters, but if its past the hole or somehow away from hole, the effetive distance become the previous strokes distance to hole - distanceToHole;
        strokedWith                     : String; // Iron/Club
        timeOfStroke                    : DateTime;
        validStroke                     : Boolean; //
        type                            : String enum {
            Regular;
            Mulligan;
            Drop;
            OOB; // Out of boundry eg. red flag.
        };
        description                     : String; // Description of stroke eg: Regular is just any valid stroke that hit within boundries;

        hole                            : Association to one game.Hole;
        windDirection                   : Integer; // 0-360 degrees
        windInMS                        : Decimal;
        temperature                     : Decimal;
        humidity                        : Decimal;
    }
}
