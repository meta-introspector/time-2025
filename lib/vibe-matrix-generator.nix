{ lib, vibeConstants, primeMappingConfig, ... }:

let
  # Helper to create a vibe row for a given prime/concept
  createVibeRow = values: values;

  # Generate the primeVibes matrix
  generatePrimeVibes = {
    # Prime 2 (Duality)
    prime2 = createVibeRow [
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # Prime 3 (Structure)
    prime3 = createVibeRow [
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # Prime 5 (Pattern)
    prime5 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # Prime 7 (Insight)
    prime7 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # Prime 11 (Transformation)
    prime11 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
    ];
    # Prime 13 (Challenge)
    prime13 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
    ];
    # Prime 17 (Communication)
    prime17 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_THREE
    ];
    # Prime 19 (Manifestation)
    prime19 = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_ONE
    ];
  };

  # Generate the conceptVibes matrix
  generateConceptVibes = {
    # list (Duality/Cons)
    list = createVibeRow [
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SEVEN
      vibeConstants.VS_POINT_EIGHT
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # ifThenElse (Structure/Form)
    ifThenElse = createVibeRow [
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SIX
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_POINT_FOUR
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
    ];
    # int (Pattern/Collection)
    int = createVibeRow [
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_EIGHT
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SIX
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
    ];
    # attrset (Insight/Guidance)
    attrset = createVibeRow [
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_NINE
      vibeConstants.VS_POINT_SEVEN
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
    ];
    # lambda (Transformation/Flow)
    lambda = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_FOUR
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_SEVEN
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SIX
      vibeConstants.VS_POINT_FOUR
      vibeConstants.VS_POINT_TWO
    ];
    # letIn (Challenge/Verification)
    letIn = createVibeRow [
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_POINT_FOUR
      vibeConstants.VS_POINT_SIX
      vibeConstants.VS_POINT_EIGHT
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SEVEN
      vibeConstants.VS_POINT_THREE
    ];
    # string (Communication/Refinement)
    string = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_POINT_TWO
      vibeConstants.VS_POINT_ONE
      vibeConstants.VS_POINT_THREE
      vibeConstants.VS_POINT_FIVE
      vibeConstants.VS_POINT_EIGHT
      vibeConstants.VS_ONE
      vibeConstants.VS_POINT_SIX
    ];
    # unsupported (Manifestation/Core Being)
    unsupported = createVibeRow [
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ZERO
      vibeConstants.VS_ONE
    ];
  };

in
{
  inherit generatePrimeVibes generateConceptVibes;
}
