(***************************************************************************)
(*     This is part of AST_AC, it is distributed under the terms of the    *)
(*             GNU Lesser General Public License version 3                 *)
(*                (see file LICENSE for more details)                      *)
(*                                                                         *)
(*            Copyright 2025-2030: Tianyu Sun, Yaoshun Fu,                 *)
(*                Ce Zhang, Si Chen and Wensheng Yu.                       *)
(***************************************************************************)


Require Export Basic_Definitions.

(** Axiom of Choice **)

(*
Definition ChoiceFunction c :=
  Function c /\ (∀ x, x ∈ dom(c) -> c[x] ∈ x).

Axiom AxiomIX : exists c, ChoiceFunction c /\ dom(c) = μ ~ [Φ].

Definition Choice_Function ε X : Prop :=
  Function ε /\ ran(ε) ⊂ X /\ dom(ε) = pow(X)~[Φ] /\ 
  (forall A, A ∈ dom(ε) -> ε[A] ∈ A).
*)

Definition Choice_Axiom : forall (X: Class),
  Ensemble X -> exists ε, Choice_Function ε X.
Proof.
  intros X HEnsX.
  unfold Ensemble in HEnsX.
  destruct AxiomIX as [c [HChoiceFunc HChoiceDom]].
  destruct HChoiceFunc.

  (* 定义选择函数 ε : c 在 Dom 上的限制. Dom 为 pow( X) ~ [Φ] *)
  set (Dom := \{ λ A, A ⊂ X /\ A ≠ Φ \}).
  set (ε := Restriction c Dom).

  (* 验证 ε 是一个函数 *)
  assert (HεFunc : Function ε).
  {
    apply (MKT126a c Dom); auto.
  }
  
  (* 验证 ε 的定义域是 X 的非空子集 *)
  assert (HεDom : dom(ε) = Dom).
  {
    apply (MKT126b c Dom) in H; unfold ε.
    rewrite H; rewrite HChoiceDom; apply AxiomI; split.
    - apply MKT4'; auto.
    - intros; apply MKT4'; split; auto.
      unfold Setminus; apply MKT4'; split.
      -- appA2H H1; apply MKT19b; auto.
      -- unfold Dom in H1; appA2H H1; destruct H2.
         unfold Complement. appA2G. unfold NotIn.
         intro; eins H4.
  }

  assert(HDompowΦ :Dom = pow( X) ~ [Φ]).
  {
    unfold Dom. unfold PowerClass. eqext.
    - appA2G; appA2H H1. destruct H2. split.
      -- appA2G.
      -- appA2G; unfold NotIn. intro; eins H4.
    - appA2G; appA2H H1. destruct H2. split.
      -- appA2H H2; auto.
      -- appA2H H3. unfold NotIn in H4. intro. destruct H4. appA2G.
  }

  (* 验证 ε 的性质：对于任何 A ∈ dom(ε)，有 ε[A] ∈ A *)
  assert (HεChoice : forall A, A ∈ dom(ε) -> ε[A] ∈ A).
  {
    intros A HAdom.
    New HAdom.
    apply (MKT126c c Dom) in HAdom; auto.
    unfold ε; rewrite HAdom.
    rewrite HεDom in H1.
    assert(A ∈ dom( c)).
    {
      rewrite HChoiceDom.
      unfold Setminus; apply MKT4'; split.
      -- appA2H H1; apply MKT19b; auto.
      -- unfold Dom in H1.
         appA2H H1; destruct H2.
         unfold Complement. appA2G; unfold NotIn.
         intro; eins H4.
    }
    apply (H0 A) in H2; auto.
  }

  (* 验证 ε 的值域是 X 的子集 *)
  assert (HεRan : ran(ε) ⊂ X).
  { 
    (* [A, y] ∈ ε , A ∈ Dom , y ∈ ran( ε) *)
    intros y Hy. New Hy; rename H1 into Hy_ran; unfold Range.
    apply AxiomII in Hy; destruct Hy as [Ey [A HεValue]].
    New HεValue; apply AxiomII in HεValue; destruct HεValue; destruct H3.
    unfold Cartesian in H4; appA2H H4; clear H4; destruct H5, H4, H4, H5.
    New H2. apply MKT49c1 in H7. New H2. apply MKT49c2 in H8. 
    apply (MKT55 A y x x0) in H4; auto. destruct H4.
    rewrite <- H4 in H5; rewrite <- H9 in H6; clear H4 H9.
    rename H5 into HA_Dom; rename H7 into EA; rename H1 into EAy. 
    clear H2 H3 H6 H8.
    (* A ∈ Dom --> A ⊂ X *)
    New HA_Dom; unfold Dom in H1; appA2H H1; destruct H2.
    (* A ∈ Dom --> ε [A] ∈ A *)
    rewrite <- HεDom in HA_Dom; New HA_Dom; apply HεChoice in H4.
    (* ε [A] = y --> y ∈ A *)
    New HA_Dom; apply Property_Value in H5; auto.
    New HεFunc; unfold Function in H6; destruct H6 as [_ H6].
    New EAy; apply (H6 A ε[A] y) in H7; auto.
    rewrite H7 in H4.
    (* y ∈ X *)
    unfold Included in H2; apply H2 in H4; auto.
  }
  exists ε. (* 构造选择函数 ε *)
  split; auto. (* ε 是一个函数 *)
  split; auto. (* 值域是 X 的子集 *)
  split; auto. (* 满足Choice_Function *)
  rewrite HεDom; rewrite HDompowΦ; auto. (* 定义域是 pow( X) ~ [Φ] *)
Qed.



(** Tukey's Lemma **)

(* Hypotheses *)

Definition En_F' F f := \{ λ x, x ∈ (∪f) /\ (F ∪ [x]) ∈ f \}.

Definition eq_dec (A : Type) := forall x y: A, {x = y} + {x <> y}.
Parameter beq : eq_dec Class.
Definition Function_χ (F f ε: Class) : Class :=
  match beq ((En_F' F f) ~ F) Φ with
  | left _ => F
  | right _ => F ∪ [ε[(En_F' F f)~F]]
  end.

Definition tSubset f' f ε : Prop :=
  f' ⊂ f /\ Φ∈f' /\ (forall F, F∈f' -> (Function_χ F f ε) ∈ f')
  /\ (forall φ, φ ⊂ f' /\ Nest φ -> (∪φ) ∈ f').

Definition tSub_f'0 f ε := ∩ \{ λ f', tSubset f' f ε \}.

Definition En_u C f ε := \{ λ A, A ∈ (tSub_f'0 f ε) /\ (A ⊂ C \/ C ⊂ A) \}.

Definition En_f'1 f ε : Class :=
  \{ λ C, C ∈ (tSub_f'0 f ε) /\ (En_u C f ε) = (tSub_f'0 f ε) \}.

Definition En_ν D f ε : Class :=
  \{ λ A, A ∈ (tSub_f'0 f ε) /\ (A⊂D \/ (Function_χ D f ε) ⊂ A) \}.


(* Property Proof *)

Lemma Property_Φ : forall x y, y ⊂ x -> x ~ y = Φ <-> x = y.
Proof.
  intros; split; intros.
  - apply Property_ProperIncluded in H; destruct H; auto.
    apply Property_ProperIncluded' in H; destruct H as [z H], H.
    assert (z ∈ (x ~ y)).
    { unfold Setminus; apply MKT4'; split; auto.
      unfold Complement; apply AxiomII; split; unfold Ensemble; eauto. }
    rewrite H0 in H2; feine z; apply H2.
  - rewrite <- H0; apply AxiomI; split; intros.
    + unfold Setminus in H1; apply MKT4' in H1.
      destruct H1; unfold Complement in H2.
      apply AxiomII in H2; destruct H2; contradiction.
    +  feine z; auto.
Qed.

Lemma Property_χ : forall ε F f,
  Choice_Function ε (∪f) -> F∈f -> F ⊂ (Function_χ F f ε).
Proof.
  intros.
  generalize (classic ((En_F' F f) ~ F = Φ)); intros; destruct H1.
  - unfold Function_χ; destruct (beq (En_F' F f ~ F) Φ); try tauto.
    unfold Included; intros; auto.
  - unfold Function_χ; destruct (beq (En_F' F f ~ F) Φ); try tauto.
    unfold Included; intros; apply MKT4; tauto.
Qed.

Lemma Ens_F'F : forall f F, Ensemble (∪ f) -> Ensemble (En_F' F f ~ F).
Proof.
  intros.
  assert (En_F' F f ~ F ⊂ ∪ f).
  { unfold Included; intros.
    unfold Setminus in H0; apply MKT4' in H0; destruct H0.
    unfold En_F' in H0; apply AxiomII in H0; apply H0. }
  apply MKT33 in H0; auto.
Qed.

Lemma Property_f'0 : forall f ε,
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) -> tSubset (tSub_f'0 f ε) f ε
  /\ (forall f', f' ⊂ f /\ tSubset f' f ε -> (tSub_f'0 f ε) ⊂ f').
Proof.
  intros; New H.
  apply Property_FinSet in H; unfold FiniteSet in H1; destruct H1, H1.
  apply NEexE in H2. destruct H2 as [F H2]; split.
  - assert (tSubset f f ε).
    { unfold tSubset; repeat split; try apply H; intros.
      - unfold Included; intros; auto.
      - generalize (MKT26 F); intros.
        apply H with (A:=F); split; auto.
      - generalize (classic((En_F' F0 f) ~ F0 = Φ)); intros; destruct H5.
        + unfold Function_χ; destruct (beq (En_F' F0 f ~ F0) Φ); tauto.
        + New H5; unfold Function_χ.
          destruct (beq (En_F' F0 f ~ F0) Φ); try tauto.
          unfold Choice_Function in H0; destruct H0, H7, H8.
          assert ((En_F' F0 f ~ F0) ∈ dom( ε)).
          { rewrite H8; unfold Setminus at 2; apply MKT4'; split.
            - unfold PowerClass; apply AxiomII; apply AxiomVI in H1.
              split; try (apply Ens_F'F); auto.
              unfold Included; intros; unfold Setminus in H10.
              apply MKT4' in H10; destruct H10.
              unfold En_F' in H10; apply AxiomII in H10; apply H10.
            - unfold Complement; apply AxiomII; New H1.
              apply AxiomVI in H10; split; try (apply Ens_F'F); auto.
              intro; unfold Singleton in H11; apply AxiomII in H11.
              destruct H11; rewrite H12 in H6; try contradiction.
              apply MKT19; generalize (MKT26 f); intros.
              apply MKT33 in H13; auto. }
           apply H9 in H10; unfold Setminus in H10.
           apply MKT4' in H10; destruct H10.
           unfold En_F' at 2 in H10; apply AxiomII in H10; apply H10. }
    assert ((tSub_f'0 f ε) ⊂ f).
    { unfold tSub_f'0; unfold Included; intros.
      unfold Element_I in H5; apply AxiomII in H5.
      apply H5; apply AxiomII; split; auto. }
    unfold tSubset; repeat split; auto.
    + unfold tSub_f'0; apply AxiomII; split; intros.
      * generalize (MKT26 f); intros; apply MKT33 in H6; auto.
      * apply AxiomII in H6; destruct H6; unfold tSubset in H7; apply H7.
    + intros; New H6; unfold Included in H5.
      apply H5 in H7; unfold tSubset in H4; apply H4 in H7.
      unfold tSub_f'0; apply AxiomII; split; intros; unfold Ensemble; eauto.
      apply AxiomII in H8; destruct H8.
      New H9; unfold tSubset in H9; apply H9.
      unfold tSub_f'0 in H6; apply AxiomII in H6; destruct H6.
      apply H11; apply AxiomII; split; auto.
    + intros; unfold tSubset in H4; destruct H6; New H6.
      apply (MKT28 H6) in H5.
      assert(φ ⊂ f /\ Nest φ); auto; clear H5. 
      apply H4 in H9; unfold tSub_f'0; apply AxiomII.
      split;  unfold Ensemble; eauto; intros; apply AxiomII in H5; destruct H5.
      unfold tSubset in H10; apply H10; split; auto.
      assert ((tSub_f'0 f ε) ⊂ y).
      { unfold Included; intros; unfold tSub_f'0 in H11.
        unfold Element_I; apply AxiomII in H11.
        destruct H11; apply H12; apply AxiomII; split; auto. }
      apply (MKT28 H8) in H11; auto.
  - intros; destruct H4; unfold Included; intros.
    unfold tSub_f'0 in H6; unfold Element_I in H6.
    apply AxiomII in H6; destruct H6; apply H7.
    apply AxiomII; apply MKT33 in H4; auto.
Qed.

Lemma FF' : forall (f ε F: Class),
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) -> F∈f ->
  (En_F' F f)~F ≠ Φ ->  F = F ∪ [ε[(En_F' F f)~F]] -> False.
Proof.
  intros.
  unfold Choice_Function in H0; assert (F~F=Φ).
  { unfold Φ; apply AxiomI; split; intros.
    - unfold Setminus in H4; apply MKT4' in H4; destruct H4.
      apply AxiomII in H5; destruct H5; contradiction.
    - apply AxiomII in H4; destruct H4; contradiction. }
  assert (F ~ F ≠ Φ); try contradiction.
  { assert ( F ~ F = (F ∪ [ε [En_F' F f ~ F]]) ~ F). { rewrite <- H3; auto. }
    rewrite H5; clear H5; apply NEexE. exists (ε [En_F' F f ~ F]).
    assert ((En_F' F f ~ F) ∈ dom( ε)).
    { destruct H0, H5, H6; rewrite H6; assert (En_F' F f ~ F ⊂ ∪ f).
      { unfold Included; intros; apply MKT4' in H8; destruct H8.
        unfold En_F' in H8; apply AxiomII in H8; apply H8. }
      assert (Ensemble (En_F' F f ~ F)).
      { apply MKT33 in H8; auto; destruct H.
        unfold FiniteSet in H; destruct H; apply AxiomVI; auto. }
      unfold Setminus at 2; apply MKT4'; split.
      - unfold PowerClass; apply AxiomII; split; auto.
      - unfold Complement; apply AxiomII; split; auto.
        unfold NotIn; intro; unfold Singleton in H10.
        apply AxiomII in H10; destruct H10; assert (Φ ∈ μ).
        { apply MKT19; generalize (MKT26 (∪ f)); intros.
          unfold FiniteSet in H; destruct H.
          apply MKT33 in H12; auto; apply AxiomVI; apply H. }
        apply H11 in H12; contradiction. }
    apply H0 in H5; unfold Setminus in H5.
    apply AxiomII in H5; destruct H5, H6; unfold Setminus.
    apply MKT4'; split; auto; apply MKT4; right.
    unfold Singleton; apply AxiomII; split; auto. }
Qed.

Lemma Property_F' : forall F f, F ∈ f -> F ⊂ (En_F' F f).
Proof.
  unfold En_F', Included; intros.
  apply AxiomII; repeat split; unfold Ensemble; eauto.
  - unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto.
  - assert (F ∪ [z] = F).
    { apply AxiomI; split; intros; try (apply MKT4; tauto).
      apply MKT4 in H1; destruct H1; auto.
      unfold Singleton in H1; apply AxiomII in H1.
      destruct H1; rewrite H2; auto; apply MKT19; unfold Ensemble; eauto. }
    rewrite H1; auto.
Qed.

(*Lemma Property_ProperIncluded'' : forall (x y: Class),
  x ⊂ y \/ y ⊂ x -> ~ (x ⊂ y) -> y ⊊ x.
Proof.
  intros; destruct H.
  - elim H0; auto.
  - unfold ProperIncluded; split; auto.
    intro; rewrite H1 in H.
    pattern x at 2 in H; rewrite <- H1 in H.
    contradiction.
Qed.*)

(* Lemma Proof *)

Lemma LemmaT1 : forall f ε,
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) ->
  (forall D, D ∈ (En_f'1 f ε) -> tSubset (En_ν D f ε) f ε).
Proof.
  intros.
  apply (Property_f'0 _ ε) in H; auto; destruct H.
  assert ((En_ν D f ε) ⊂ f).
  { unfold En_ν; unfold Included; intros.
    apply AxiomII in H3; destruct H3, H4.
    unfold tSubset in H; destruct H.
    unfold Included in H; apply H in H4; auto. }
  unfold tSubset; repeat split; auto.
  - unfold En_ν; apply AxiomII.
    unfold tSubset in H; destruct H, H4.
    repeat split; unfold Ensemble; eauto; left; apply MKT26.
  - intro A; intros.
    New H4; unfold Included in H3; apply H3 in H4.
    unfold En_ν in H5; unfold En_ν.
    apply AxiomII; apply AxiomII in H5; destruct H5, H6.
    New H6; unfold tSubset in H; apply H in H8.
    repeat split; unfold Ensemble; eauto; destruct H7.
    + apply Property_ProperIncluded in H7. destruct H7.
      * left; generalize (classic ((Function_χ A f ε) ⊂ D)); intros.
        destruct H9; auto; unfold En_f'1 in H1; apply AxiomII in H1.
        destruct H1, H10; rewrite <- H11 in H8.
        unfold En_u in H8; apply AxiomII in H8; destruct H8, H12.
        apply Property_ProperIncluded'' in H13; auto.
        New H7; apply Property_ProperIncluded' in H7.
        New H13; apply Property_ProperIncluded' in H13.
        destruct H7, H13, H7, H13.
        generalize (classic (x=x0)); intros; destruct H18.
        -- rewrite H18 in H7; contradiction.
        -- unfold ProperIncluded in H15; destruct H15.
           unfold Included in H15; apply H15 in H7.
           assert (x0 ∉ A).
           { unfold NotIn; intro; unfold ProperIncluded in H14.
             destruct H14; unfold Included in H14.
             apply H14 in H20; contradiction. }
           generalize (classic ((En_F' A f)~A=Φ)); intros; destruct H21.
           ++ unfold Function_χ in H13; unfold NotIn in H20.
              destruct (beq (En_F' A f ~ A) Φ); tauto.
           ++ unfold Function_χ in H7, H8, H13.
              destruct (beq (En_F' A f ~ A) Φ); try tauto.
              apply MKT4 in H7; apply MKT4 in H13.
              destruct H7, H13; try contradiction.
              unfold Singleton in H13; apply AxiomII in H13.
              unfold Singleton in H7; apply AxiomII in H7; destruct H13, H7.
              apply AxiomIV' in H8; destruct H8.
              apply MKT42' in H24; apply MKT19 in H24.
              New H24; apply H22 in H24; apply H23 in H25.
              rewrite <- H24 in H25; contradiction.
      * right; rewrite H7.
        unfold Included; intros; auto.
    + apply (Property_χ ε _ _) in H4; auto.
      apply (MKT28 H7) in H4; auto.
  - intro ϑ; intros; destruct H4.
    unfold En_ν; apply AxiomII.
    assert ((∪ ϑ) ∈ (tSub_f'0 f ε)).
    { unfold tSubset in H; apply H; split; auto.
      red; intros; unfold Included in H4.
      apply H4 in H6; unfold En_ν in H6.
      apply AxiomII in H6; apply H6. }
    repeat split; unfold Ensemble; eauto.
    generalize (classic (forall B, B∈ϑ -> B ⊂ D)).
    intros; destruct H7.
    + left; unfold Included; intros.
      unfold Element_U in H8; apply AxiomII in H8.
      destruct H8, H9, H9; apply H7 in H10.
      unfold Included in H10; apply H10 in H9; auto.
    + apply not_all_ex_not in H7; destruct H7.
      apply imply_to_and in H7; destruct H7.
      New H7; unfold Included in H4; apply H4 in H7.
      unfold En_ν in H7; apply AxiomII in H7.
      destruct H7, H10, H11; try contradiction.
      right; unfold Included; intros.
      unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto.
Qed.

Lemma LemmaT2 : forall f ε,
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) ->
  (forall D, D ∈ (En_f'1 f ε) -> (Function_χ D f ε) ∈ (En_f'1 f ε)).
Proof.
  intros; New H1.
  unfold En_f'1 in H2; apply AxiomII in H2.
  destruct H2, H3; New H3; unfold tSub_f'0 in H5.
  New H; apply (Property_f'0 _ ε) in H6; auto.
  destruct H6; unfold tSubset in H6.
  New H3; apply H6 in H8; New H8.
  unfold tSub_f'0 in H9; destruct H6.
  unfold Included in H6; apply H6 in H3.
  apply (Property_χ ε _ _) in H3; auto.
  assert ((En_ν D f ε) ⊂ (En_u (Function_χ D f ε) f ε)).
  { unfold En_ν, En_u, Included; intros.
    apply AxiomII in H11; apply AxiomII; destruct H11, H12.
    repeat split; auto; destruct H13; auto. }
  assert ((En_u (Function_χ D f ε) f ε) ⊂ (tSub_f'0 f ε)).
  { unfold En_u, Included; intros.
    apply AxiomII in H12; apply H12. }
  apply (LemmaT1 f ε) in H1; auto.
  unfold FiniteSet in H; destruct H, H.
  assert ((En_ν D f ε) ⊂ f /\ tSubset (En_ν D f ε) f ε).
  { split; auto; unfold En_ν, Included; intros.
    apply AxiomII in H15; destruct H15, H16.
    apply H6 in H16; auto. }
  apply H7 in H15; apply (MKT28 H15) in H11.
  assert(En_u (Function_χ D f ε) f ε ⊂ tSub_f'0 f ε 
    /\ (tSub_f'0 f ε) ⊂ (En_u (Function_χ D f ε) f ε)); auto.
  apply MKT27 in H16; auto.
  unfold En_f'1; apply AxiomII; repeat split; unfold Ensemble; eauto.
Qed.

Lemma LemmaT3 : forall f ε,
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) -> Nest (tSub_f'0 f ε).
Proof.
  intros; New H.
  apply (Property_f'0 _ ε) in H1; auto; destruct H1.
  assert ((En_f'1 f ε) ⊂ (tSub_f'0 f ε) /\ Nest (En_f'1 f ε)).
  { assert ((En_f'1 f ε) ⊂ (tSub_f'0 f ε)).
    { unfold Included; intros.
      unfold En_f'1 in H3; apply AxiomII in H3; apply H3. }
    split; auto; unfold tSubset in H1.
    assert(En_f'1 f ε ⊂ tSub_f'0 f ε /\ ((tSub_f'0 f ε) ⊂ f)). 
    { destruct H1. split; auto.  }
    clear H3; rename H4 into H3.
    destruct H3. apply (MKT28 H3) in H4. clear H3. rename H4 into H3.
    unfold FiniteSet in H; destruct H, H.
    apply MKT33 with (z:=(En_f'1 f ε)) in H; auto.
    unfold Nest; intros; unfold En_f'1 in H6; destruct H6.
    apply AxiomII in H6; apply AxiomII in H7.
    destruct H6, H7, H8, H9; rewrite <- H11 in H8.
    unfold En_u in H8; apply AxiomII in H8; apply H8. }
  destruct H3.
  assert ((En_f'1 f ε) ⊂ f /\ tSubset (En_f'1 f ε) f ε).
  { unfold tSubset in H1.
    assert(En_f'1 f ε ⊂ tSub_f'0 f ε /\ (tSub_f'0 f ε) ⊂ f).
    { destruct H1; split; auto. }
    clear H3; rename H5 into H3; try apply H1.
    destruct H3. apply (MKT28 H3) in H5.
    clear H3. rename H5 into H3.
    unfold tSubset; repeat split; auto; intros.
    - unfold En_f'1; apply AxiomII.
      destruct H1, H5; repeat split; unfold Ensemble; eauto.
      apply AxiomI; split; intros.
      + unfold En_u; apply AxiomII in H7; apply H7.
      + unfold En_u; apply AxiomII; repeat split. unfold Ensemble; eauto. auto.
        right; apply MKT26.
    - apply (LemmaT2 _ ε); auto.
    - unfold En_f'1; apply AxiomII.
      assert ((∪ φ) ∈ (tSub_f'0 f ε)).
      { destruct H5; assert (φ ⊂ (tSub_f'0 f ε)).
        { unfold Included; intros.
          unfold Included in H5; apply H5 in H7.
          unfold En_f'1; apply AxiomII in H7; apply H7. }
        assert(φ ⊂ tSub_f'0 f ε /\ Nest φ); auto. apply H1 in H8; auto. }
      repeat split; unfold Ensemble; eauto.
      apply AxiomI; split; intros.
      + unfold En_u in H7; apply AxiomII in H7; apply H7.
      + unfold En_u; apply AxiomII; repeat split; unfold Ensemble; eauto.
        generalize (classic (forall B, B ∈ φ -> B ⊂ z)).
        intros; destruct H8.
        * right; unfold Included; intros.
          unfold Element_U in H9; apply AxiomII in H9.
          destruct H9, H10, H10; apply H8 in H11.
          unfold Included in H11; apply H11; auto.
        * apply not_all_ex_not in H8; destruct H8.
          apply imply_to_and in H8; destruct H5, H8.
          New H8; unfold Included in H5; apply H5 in H8.
          unfold En_f'1 in H8; apply AxiomII in H8; destruct H8, H12.
          rewrite <- H13 in H7; unfold En_u in H7; apply AxiomII in H7.
          destruct H7, H14; destruct H15; try contradiction.
          left; unfold Included; intros.
          unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto. }
  apply H2 in H5.
  assert(tSub_f'0 f ε ⊂ En_f'1 f ε /\ (En_f'1 f ε) ⊂ (tSub_f'0 f ε)); auto.
  apply MKT27 in H6; auto; rewrite H6; auto.
Qed.

Lemma LemmaT4 : forall f ε,
  FiniteSet f /\ f ≠ Φ -> Choice_Function ε (∪f) -> (∪ tSub_f'0 f ε) ∈ f /\
  (Function_χ (∪ (tSub_f'0 f ε)) f ε) = ∪ (tSub_f'0 f ε).
Proof.
  intros; New H.
  apply (Property_f'0 _ ε) in H1; auto.
  destruct H1; unfold tSubset in H1.
  assert ((tSub_f'0 f ε) ⊂ (tSub_f'0 f ε) /\ Nest (tSub_f'0 f ε)).
  { split; try unfold Included; auto.
    apply (LemmaT3 _ ε) in H; auto. }
  apply H1 in H3; split.
  - destruct H1; unfold Included in H1; apply H1 in H3; auto.
  - unfold tSub_f'0 at 2 in H3; destruct H1.
    unfold Included in H1; New H3; apply H1 in H5.
    apply (Property_χ ε _ _) in H5; auto.
    assert ((Function_χ (∪ (tSub_f'0 f ε)) f ε) ⊂ ∪ (tSub_f'0 f ε)).
    { apply H4 in H3; unfold Included; intros.
    unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto. }
    apply MKT27; auto.
Qed.


(* Tukey's Lemma Proof *)

Theorem Tukey : forall (f: Class),
  FiniteSet f /\ f ≠ Φ -> exists x, MaxMember x f.
Proof.
  intros; New H.
  unfold FiniteSet in H0; destruct H0, H0.
  assert (Ensemble (∪f)). { apply AxiomVI in H0; auto. }
  apply Choice_Axiom in H3; destruct H3 as [ε H3].
  assert (exists F, F∈f /\ (En_F' F f) ~ F = Φ).
  { exists (∪(tSub_f'0 f ε)); New H3.
    apply (LemmaT4 _ ε) in H4; auto; destruct H4; split; auto.
    generalize (classic(En_F'(∪ tSub_f'0 f ε)f~(∪ tSub_f'0 f ε)=Φ)).
    intros; destruct H6; auto.
    assert ((Function_χ (∪ (tSub_f'0 f ε)) f ε) = (∪ tSub_f'0 f ε) ∪
    [ε [En_F' (∪ tSub_f'0 f ε) f ~ (∪ tSub_f'0 f ε)]]).
    { unfold Function_χ; destruct (beq (En_F' (∪ tSub_f'0 f ε) f ~
      (∪ tSub_f'0 f ε)) Φ); tauto. }
    rewrite H5 in H7; apply FF' in H7; auto; inversion H7. }
  destruct H4 as [F H4]; destruct H4; exists F.
  apply -> Property_Φ in H5; try (apply Property_F'; auto).
  unfold MaxMember; intro; clear H6; repeat split; auto; intros F' H6; intro.
  New H7; rewrite <- H5 in H8; apply Property_ProperIncluded' in H8.
  destruct H8 as [z H8], H8; assert (F' ⊂ (En_F' F f)).
  { unfold En_F', Included; intros; apply AxiomII; repeat split;
    unfold Ensemble; eauto.
    - unfold Element_U; apply AxiomII; split; unfold Ensemble; eauto.
    - assert ((F ∪ [z0]) ⊂ F').
      { unfold ProperIncluded in H7; destruct H7.
        unfold Included in H7; unfold Included; intros.
        apply MKT4 in H12; destruct H12; try (apply H7 in H12; auto).
        unfold Singleton in H12; apply AxiomII in H12.
        destruct H12; rewrite H13; auto; apply MKT19; unfold Ensemble; eauto. }
      apply Property_FinSet in H; apply H with (A:= F'); split; auto. }
  unfold Included in H10; apply H10 in H8; contradiction.
Qed.
