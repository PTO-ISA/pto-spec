// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-PROFILE-EXPONENTIAL-008","source":"asl/arch/profile/reference-profile.asl","requirements":[],"kind":"execution","summary":"the reference profile evaluates a nonzero exponential through the fixed 18-term algorithm","pass_condition":"FloatingExponential(2.0) falls inside the independently fixed narrow interval that excludes the 17-term result","related_sources":[]}
func main() => integer
begin
    let exponential_two = FloatingExponential(2.0);

    // The 17-term result is below 7.38905609892.  The 18-term reference result
    // is approximately 7.389056098925863, so this interval distinguishes the
    // final required term without reproducing the implementation loop.
    assert exponential_two > 7.38905609892;
    assert exponential_two < 7.38905609893;
    return 0;
end;
