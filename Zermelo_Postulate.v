(***************************************************************************)
(*     This is part of AST_AC, it is distributed under the terms of the    *)
(*             GNU Lesser General Public License version 3                 *)
(*                (see file LICENSE for more details)                      *)
(*                                                                         *)
(*            Copyright 2025-2030: Tianyu Sun, Yaoshun Fu,                 *)
(*                Ce Zhang, Si Chen and Wensheng Yu.                       *)
(***************************************************************************)


Require Export Maximal_Principle.


(** Zermelo Postulate **)

Definition En_TB B A : Class :=
  \{ λ k, k ⊂ ∪A /\ (forall a, a ∈ (A ~ B) -> a ∩ k = Φ) /\
  (forall a, a ∈ B -> exists x, a ∩ k = [x]) \}.

Definition En_T A : Class :=
  \{ λ k, exists B, B ⊂ A /\ k ∈ (En_TB B A) \}.

Lemma Contrapositive : forall A B, (A<->B) -> (~ A) -> (~ B).
Proof. unfold not; intros; apply H in H1; apply H0 in H1; auto. Qed.

Lemma Property_Φ : forall x y, y ⊂ x -> x ~ y = Φ <-> x = y.
Proof.
  intros; split; intros.
  - apply Property_ProperIncluded in H; destruct H; auto.
    apply Property_ProperIncluded' in H; destruct H as [z H], H.
    assert (z ∈ (x ~ y)).
    { unfold Setminus; apply MKT4'; split; auto.
      unfold Complement; apply AxiomII; split; unfold Ensemble; eauto. }
    rewrite H0 in H2; feine z; auto.
  - rewrite <- H0; apply AxiomI; split; intros.
    + unfold Setminus in H1; apply MKT4' in H1.
      destruct H1; unfold Complement in H2.
      apply AxiomII in H2; destruct H2; contradiction.
    + feine z; auto.
Qed.

Lemma notorand : ∀ P Q,
  (~(P \/ Q) -> (~P) /\ (~Q)).
Proof.
  intros; destruct (classic P); tauto.
Qed.

Theorem Zermelo : forall A,
  Ensemble A -> Φ ∉ A ->
  (forall x y, x ∈ A /\ y ∈ A -> x ≠ y -> x ∩ y = Φ) ->
  (exists D, Ensemble D /\ (forall B, B ∈ A -> exists x, B ∩ D = [x])).
Proof.
  intros.
  generalize (classic (A = Φ)); intros; destruct H2.
  - rewrite H2 in *; clear H2; exists Φ; split; intros; auto.
    feine B; auto.
  - assert (Ensemble (En_T A)).
    { apply AxiomVI in H; apply MKT38a in H; auto.
      assert (En_T A ⊂ pow(∪A)).
      { unfold Included; intros; apply AxiomII in H3; destruct H3.
        destruct H4 as [B H4], H4; unfold En_TB in H5.
        apply AxiomII in H5; destruct H5, H6.
        unfold PowerClass; apply AxiomII; split; auto. }
      apply MKT33 in H3; auto. }
    assert (En_T A ≠ Φ).
    { apply NEexE in H2; destruct H2.
      generalize (classic (x = Φ)); intros; destruct H4.
      - rewrite H4 in H2; contradiction.
      - apply NEexE in H4; destruct H4.
        apply NEexE; exists [x0]; unfold En_T.
        assert (Ensemble x0); unfold Ensemble; eauto.
        apply MKT42 in H5; auto.
        apply AxiomII; split; auto; exists [x]; repeat split.
        + unfold Included, Singleton; intros; apply AxiomII in H6.
          destruct H6; rewrite H7; try apply MKT19; unfold Ensemble; eauto.
        + unfold En_TB; apply AxiomII; repeat split; auto; intros.
          * unfold Included; intros; apply AxiomII in H6; destruct H6.
            rewrite H7; try apply MKT19; unfold Ensemble; eauto;
            apply AxiomII; unfold Ensemble; eauto. 
          * unfold Setminus in H6. apply MKT4' in H6; destruct H6.
            assert (x ∈ A /\ a ∈ A); auto; apply H1 in H8.
            { generalize (classic (a ∩ [x0] = Φ)); intros; destruct H9; auto.
              apply NEexE in H9; destruct H9.
              apply MKT4' in H9; destruct H9; apply AxiomII in H10.
              destruct H10; rewrite H11 in *. 
              assert (x0 ∈ (x ∩ a)); try apply MKT4'; auto.
              rewrite H8 in H12; feine x0; auto. 
              apply MKT19; unfold Ensemble; eauto.
              apply MKT19; unfold Ensemble; eauto. }
            { intro; rewrite H9 in H7; unfold Complement in H7.
              apply AxiomII in H7; destruct H7, H10; unfold Singleton.
              apply AxiomII; split; auto. }
          * exists x0; apply AxiomII in H6; destruct H6.
            rewrite H7 in *; try apply MKT19; unfold Ensemble; eauto. 
            apply AxiomI; split; intros.
            -- apply MKT4' in H8; apply H8.
            -- apply MKT4'; split; auto; apply AxiomII in H8.
               destruct H8; rewrite H9; try apply MKT19; unfold Ensemble; eauto. } 
    apply MaxPrinciple in H3.
    + destruct H3 as [C H3]; unfold MaxMember in H3.
      apply H3 in H4; clear H3; destruct H4; exists C; split; unfold Ensemble; eauto. 
      unfold En_T in H3; apply AxiomII in H3; destruct H3. 
      destruct H5 as [B H5], H5.
      generalize (classic (B = A)); intro; destruct H7.
      * rewrite H7 in H6; apply AxiomII in H6; apply H6.
      * New H5; apply Property_Φ in H8; assert (A ~ B <> Φ).
        { intro; apply H8 in H9; symmetry in H9; tauto. }
        clear H7 H8; apply NEexE in H9; destruct H9.
        unfold Setminus in H7; apply MKT4' in H7; destruct H7.
        generalize (classic (x = Φ)); intro; destruct H9;
        try (rewrite H9 in H7; contradiction).
        apply NEexE in H9; destruct H9.
        assert ((C ∪ [x0]) ∈ (En_T A)).
        { unfold En_T; apply AxiomII; split.
          - apply AxiomIV; try apply MKT42; unfold Ensemble; eauto.
          - exists (B ∪ [x]); repeat split.
            + unfold Included; intros; apply MKT4 in H10.
              destruct H10; auto; apply AxiomII in H10; destruct H10.
              rewrite H11; try apply MKT19; unfold Ensemble; eauto.
            + apply AxiomII; repeat split; intros.
              * apply AxiomIV; try apply MKT42; unfold Ensemble; eauto.
              * unfold Included; intros; apply MKT4 in H10; destruct H10.
                { apply AxiomII in H6; apply H6 in H10; auto. }
                { unfold Singleton in H10; apply AxiomII in H10; destruct H10.
                  rewrite H11; try apply MKT19; unfold Ensemble; eauto; 
                  unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto. }
              * apply AxiomII in H6; unfold Setminus in H10.
                apply MKT4' in H10; destruct H10; rewrite MKT8.
                unfold Complement in H11; apply AxiomII in H11; destruct H11.
                assert (a ∈ (B ∪ [x]) <-> a ∈ B \/ a ∈ [x]).
                { split; try apply MKT4. }
                assert(~ (a ∈ B \/ a ∈ [x])). 
                { unfold not; intros; New H14; apply H13 in H14; auto. }
                auto; clear H12; clear H13; rename H14 into H13.
                assert(~ a ∈ B /\ ~ a ∈ [x]). 
                { split; unfold not in H13; unfold not; intros; auto. } 
                clear H13; rename H12 into H13.
                destruct H13.
                assert (a ∈ (A ~ B)).
                { unfold Setminus; apply MKT4'; split; auto.
                  unfold Complement; apply AxiomII; auto. }
                apply H6 in H14; rewrite H14; clear H14.
                assert (x ∈ A /\ a ∈ A); auto; apply H1 in H14.
                { generalize (classic (a ∩ [x0] = Φ)); intros; destruct H15.
                  - rewrite H15; apply MKT5.
                  - apply NEexE in H15; destruct H15; apply MKT4' in H15;
                    destruct H15; apply AxiomII in H16; destruct H16;
                    rewrite H17 in *; try apply MKT19; unfold Ensemble; eauto.
                    assert (x0 ∈ (x ∩ a)); try apply MKT4'; auto.
                    rewrite H14 in H18; apply MKT16 in H18; contradiction. }
                { intro; rewrite H15 in H13; destruct H13; unfold Singleton.
                  apply AxiomII; split; auto. }
              * apply AxiomII in H6; rewrite MKT8.
                apply MKT4 in H10; destruct H10.
                { New H10; apply H6 in H11; destruct H11; rewrite H11.
                  clear H11; assert (x ∈ A /\ a ∈ A); auto; apply H1 in H11.
                  - generalize (classic (a ∩ [x0] = Φ)); intros; destruct H12.
                    + rewrite H12; rewrite MKT6, MKT17; unfold Ensemble; eauto.
                    + apply NEexE in H12; destruct H12; apply MKT4' in H12;
                      destruct H12; apply AxiomII in H13; destruct H13;
                      rewrite H14 in *; try apply MKT19; unfold Ensemble; eauto.
                      assert (x0 ∈ (x ∩ a)); try apply MKT4'; auto.
                      rewrite H11 in H15; apply MKT16 in H15; contradiction.
                  - intro; rewrite <- H12 in H10; unfold Complement in H8.
                    apply AxiomII in H8; destruct H8; contradiction. }
                { unfold Singleton in H10; apply AxiomII in H10; destruct H10.
                  rewrite H11; try apply MKT19; unfold Ensemble; eauto; clear H10 H11 a.
                  assert (x ∈ (A ~ B)); try apply MKT4'; auto.
                  apply H6 in H10; rewrite H10, MKT17; exists x0.
                  apply AxiomI; split; intros.
                  - apply MKT4' in H11; apply H11.
                  - apply MKT4'; split; auto; apply AxiomII in H11.
                    destruct H11; rewrite H12; try apply MKT19; unfold Ensemble; eauto. } }
        apply H4 in H10; destruct H10; unfold ProperIncluded.
        split; unfold Included; intros; try (apply MKT4; auto).
        apply AxiomII in H6; assert (x ∈ (A ~ B)); try apply MKT4'; auto.
        apply H6 in H10; intro; assert (x0 ∈ Φ).
        { rewrite <- H10; apply MKT4'; split; auto; rewrite H11.
          apply MKT4; right; apply AxiomII; split; unfold Ensemble; eauto. }
          feine x0; auto.
    + intros; exists (∪n); split; intros.
      * apply Property_FinSet in H5; auto; split; auto; clear H6.
        destruct H5; unfold FiniteSet; repeat split; auto.
        { intros F H7 F1 H8; destruct H8; unfold En_T in H7.
          apply AxiomII in H7; destruct H7, H10 as [B H10], H10.
          unfold En_T; apply AxiomII; assert (Ensemble F1).
          { apply MKT33 in H8; auto. }
          split; auto; unfold En_TB in H11; apply AxiomII in H11.
          destruct H11 as [_ H11], H11.
          exists \{ λ a, a ∈ B /\ exists x, a ∩ F1 = [x] \}; repeat split.
          - unfold Included; intros; apply AxiomII in H14; destruct H14, H15.
            apply H10 in H15; auto.
          - apply AxiomII; repeat split; auto; intros.
            + apply (MKT28 H8) in H11; auto.
            + apply MKT4' in H14; destruct H14; apply AxiomII in H15.
              destruct H15 as [_ H15]; unfold NotIn in H15.
              assert(~ (Ensemble a /\ a ∈ B /\ (∃x : Class,a ∩ F1 = [x]))).
              { unfold not; intros; destruct H16, H17; unfold not in H15. 
                apply H15; apply AxiomII; split; auto. }
              clear H15; rename H16 into H15.
              apply notandor in H15; destruct H15.
                { destruct H15; unfold Ensemble; eauto. }
                { apply notandor in H15; destruct H15.
                  - assert (a ∈ (A ~ B)).
                    { unfold Setminus; apply MKT4'; split; auto.
                      unfold Complement; apply AxiomII; split; 
                      unfold Ensemble; eauto. }
                    apply H13 in H16; apply MKT27;split;try apply MKT26.
                    rewrite <- H16; unfold Included; intros; apply MKT4' in H17.
                    apply MKT4'; destruct H17; unfold Ensemble; eauto.
                  - generalize (classic (a ∈ B)); intros; destruct H16.
                    + apply H13 in H16; destruct H16.
                      apply not_ex_all_not with (n:= x) in H15.
                      generalize (classic (a∩F1=Φ)); intros; destruct H17; auto.
                      apply NEexE in H17; destruct H17 as [z H17].
                      assert ((a ∩ F1) ⊂ [x]).
                      { unfold Included; intros; rewrite <- H16.
                        apply MKT4' in H18; apply MKT4'; destruct H18.
                        split; auto. }
                      New H17; apply H18 in H19; unfold Singleton in H19.
                      apply AxiomII in H19; destruct H19.
                      assert ([x] ⊂ (a ∩ F1)).
                      { unfold Included; intros; unfold Singleton in H21.
                        apply AxiomII in H21; destruct H21.
                        assert (Ensemble x).
                        { apply MKT42'; rewrite <- H16; apply MKT33 with (x:= a).
                          unfold Ensemble; eauto. unfold Included.
                          intros; apply MKT4' in H23; apply H23. }
                        rewrite H22, <- H20; try apply MKT19; 
                        unfold Ensemble; eauto. }
                      assert ((a ∩ F1) ⊂ [x] /\ [x] ⊂ (a ∩ F1)); auto.
                      apply MKT27 in H22; rewrite H22 in H15; tauto.
                    + assert (a ∈ (A ~ B)).
                      { unfold Setminus; apply MKT4'; split; auto.
                        unfold Complement; apply AxiomII; split; 
                        unfold Ensemble; eauto. }
                      apply H13 in H17; apply MKT27.
                      split; try apply MKT26; rewrite <- H17.
                      unfold Included; intros; apply MKT4' in H18.
                      apply MKT4'; destruct H18; unfold Ensemble; eauto. }
            + apply AxiomII in H14; apply H14. }
        { intros; destruct H7.
          generalize (classic (F ∈ (En_T A))); intros; destruct H9; auto.
          assert (forall B, B ⊂ A -> ~ F ∈ (En_TB B A)).
          { intros; unfold En_T in H9.
            assert(~ (Ensemble F /\ (∃B : Class,B ⊂ A /\ F ∈ (En_TB B A)))).
            { unfold not; intros; destruct H11, H12, H12; unfold not in H9. 
                apply H9; apply AxiomII; split; auto. exists x; split; auto. }
            clear H9; rename H11 into H9.
            apply notandor in H9; destruct H9; try tauto.
            apply not_ex_all_not with (n:= B) in H9.
            apply notandor in H9; tauto. }
          set (B:= \{ λ a, a ∈ A /\ a ∩ F <> Φ /\ ~ (∃x, a ∩ F = [x]) \} ∪
          \{ λ a, a ∈ A /\ a ∩ F <> Φ /\ (∃x, a ∩ F = [x]) \}).
          assert (B ⊂ A).
          { unfold Included; intros; apply MKT4 in H11.
            destruct H11; apply AxiomII in H11; apply H11. }
          apply H10 in H11; unfold En_TB in H11.
          apply Contrapositive with (B:= Ensemble F /\ F ⊂ ∪ A /\ (∀a, 
          a ∈ (A ~ B) -> a ∩ F = Φ) /\ (∀a, a ∈ B -> ∃x, a ∩ F = [x])) in H11.
          - apply notandor in H11; destruct H11; try tauto.
            apply notandor in H11; destruct H11.
            + assert (forall z, z ⊂ F /\ Finite z -> z ⊂ ∪ A).
              { intros; apply H8 in H12; unfold En_T in H12.
                apply AxiomII in H12; destruct H12, H13, H13.
                unfold En_TB in H14; apply AxiomII in H14; apply H14. }
              destruct H11; unfold Included; intros.
              assert ([z] ⊂ F /\ Finite ([z])).
              { split; try apply finsin
; unfold Ensemble; eauto; unfold Included; intros.
                unfold Singleton in H13; apply AxiomII in H13; destruct H13.
                rewrite H14; try apply MKT19; unfold Ensemble; eauto. }
              apply H12 in H13; apply H13; unfold Singleton.
              apply AxiomII; split; unfold Ensemble; eauto.
            + apply notandor in H11; destruct H11.
              * apply not_all_ex_not in H11.  destruct H11 as [a H11].
                apply imply_to_and in H11; destruct H11.
                unfold Setminus in H11; apply MKT4' in H11; destruct H11.
                unfold Complement in H13; apply AxiomII in H13; destruct H13.
                unfold NotIn in H14; apply Contrapositive with (B:= a ∈ \{λ a, 
                a∈A /\ a ∩ F <> Φ /\ ~ (∃ x, a ∩ F = [x])\} \/ a ∈ \{ λ a, 
                a ∈ A /\ a ∩ F <> Φ /\ (∃ x, a ∩ F = [x]) \}) in H14.
                { apply notorand in H14; destruct H14.
                  apply Contrapositive with (B:= Ensemble a /\ a ∈ A /\
                  a ∩ F <> Φ /\ ~ (∃ x, a ∩ F = [x])) in H14.
                  - apply Contrapositive with (B:= Ensemble a /\ a ∈ A /\ 
                    a ∩ F <> Φ /\ (∃ x, a ∩ F = [x])) in H15; try tauto.
                    split; intros; try apply AxiomII; auto.
                    apply AxiomII in H16; auto.
                  - split; intros; try apply AxiomII; auto.
                    apply AxiomII in H16; auto. }
                { split; intros; try apply MKT4; auto. }
              * apply not_all_ex_not
 in H11; destruct H11 as [a H11].
                apply imply_to_and in H11; destruct H11.
                apply MKT4 in H11; destruct H11.
                { apply AxiomII in H11; clear B H12; destruct H11, H12, H13.
                  assert (~ (forall x y, x ∈ (a ∩ F) /\ y ∈ (a ∩ F) -> x = y)).
                  { intro; apply NEexE in H13; destruct H13, H14.
                    exists x; apply AxiomI; split; intros.
                    - assert(z ∈ a ∩ F /\ x ∈ (a ∩ F)); auto; clear H14.
                      rename H16 into H14; apply H15 in H14; rewrite H14.
                      unfold Singleton; apply AxiomII; unfold Ensemble; eauto.
                    - unfold Singleton in H14; apply AxiomII in H14; destruct H14.
                      rewrite H16; try apply MKT19; unfold Ensemble; eauto. }
                  destruct H15; intros; destruct H15.
                  generalize (classic (x = y)); intros; destruct H17; auto.
                  apply MKT4' in H15; apply MKT4' in H16.
                  destruct H15, H16.
                  assert ([x|y] ⊂ F /\ Finite ([x|y])).
                  { split.
                    - unfold Included; intros; apply MKT46b in H20;
                      unfold Ensemble; eauto; destruct H20; rewrite H20; auto.
                    - unfold Unordered; apply MKT168.
                      apply finsin ; unfold Ensemble; eauto.
                      apply finsin ; unfold Ensemble; eauto. }
                  apply H8 in H20; unfold En_T in H20; apply AxiomII in H20.
                  destruct H20, H21 as [B H21], H21; unfold En_TB in H22.
                  apply AxiomII in H22; destruct H22, H23.
                  generalize (classic (a ∈ B)); intros; destruct H25.
                  - apply H24 in H25; destruct H25.
                    assert ([x | y] ⊂ a).
                    { unfold Included; intros; apply MKT46b in H26;
                      unfold Ensemble; eauto; destruct H26; rewrite H26; auto. }
                    apply MKT30 in H26; rewrite MKT6' in H26.
                    rewrite H26 in H25; clear H26; destruct H17.
                    assert (x ∈ [x0] /\ y ∈ [x0]).
                    { rewrite <- H25; split; apply MKT46b; 
                      unfold Ensemble; eauto. }
                    destruct H17; apply AxiomII in H17.
                    apply AxiomII in H26; destruct H17, H26.
                    assert (x0 ∈ μ).
                    { apply MKT19; apply MKT42'; rewrite <- H25.
                      apply MKT46a; unfold Ensemble; eauto. }
                    rewrite H27, H28; auto.
                  - assert (a ∈ (A ~ B)).
                    { unfold Setminus; apply MKT4'; split; auto.
                      unfold Complement; apply AxiomII; split;
                      unfold Ensemble; eauto. }
                    apply H24 in H26; clear H24.
                    assert ([x | y] ⊂ a).
                    { unfold Included; intros; apply MKT46b in H24;
                      unfold Ensemble; eauto; destruct H24; rewrite H24; auto. }
                    apply MKT30 in H24; rewrite MKT6' in H24.
                    rewrite H24 in H26; clear H24.
                    assert (x ∈ Φ). { rewrite <- H26; apply MKT46b;
                    unfold Ensemble; eauto. }
                   feine x; auto. }
                { apply AxiomII in H11; destruct H11, H13, H14; tauto. }
          - split; intros; try apply AxiomII; try apply AxiomII in H12; auto. }
      * unfold Included; intros; apply AxiomII; split; unfold Ensemble; eauto.
Qed.
