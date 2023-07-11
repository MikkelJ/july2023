using golf from '../db/schema';

service CatalogService @(path: '/browse') {
    
    entity PlayerSet as projection on golf.Player;

    
    //########################################################################################
    //##########################      location Context  ######################################
    //########################################################################################

    entity ClubSet as projection on golf.location.Club;
    entity CourseSet as projection on golf.location.Course;
    entity CourseHoleSet as projection on golf.location.Hole;
    entity CourseHoleVariantSet as projection on golf.location.Hole_Variant;

    //########################################################################################
    //##########################      Game Context      ######################################
    //########################################################################################

    entity TournamentSet as projection on golf.game.Tournament;
    entity RoundSet as projection on golf.game.Round;
    entity ScoreCardSet as projection on golf.game.ScoreCard;
    entity GameHoleSet as projection on golf.game.Hole;
    entity StrokeSet as projection on golf.game.Stroke;
    
}