package com.example.doghandoffcard;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

public final class MainActivity extends Activity {
    private static final String PREFS_NAME = "dog-handoff-draft";

    private EditText dogNameField;
    private EditText ageField;
    private EditText breedField;
    private EditText weightField;
    private EditText temperamentField;
    private EditText doNotDoField;
    private EditText feedingField;
    private EditText waterField;
    private EditText walksField;
    private EditText foodsToAvoidField;
    private EditText medicationNameField;
    private EditText medicationDoseField;
    private EditText medicationTimeField;
    private EditText missedDoseField;
    private EditText ownerPhoneField;
    private EditText clinicPhoneField;
    private EditText caregiverField;
    private EditText caregiverTypeField;
    private EditText tripNoteField;
    private TextView readinessOutput;
    private TextView cardOutput;
    private Button shareButton;
    private String latestPlainText = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ScrollView scrollView = new ScrollView(this);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(32, 96, 32, 32);
        scrollView.addView(content);

        TextView title = new TextView(this);
        title.setText("DogHandoffCard");
        title.setTextSize(28);
        title.setTextColor(Color.rgb(40, 40, 40));
        content.addView(title);

        TextView intro = new TextView(this);
        intro.setText("Create a caregiver-ready Android handoff card for a senior dog.");
        intro.setTextSize(16);
        intro.setPadding(0, 8, 0, 24);
        content.addView(intro);

        dogNameField = addField(content, "Dog name");
        ageField = addField(content, "Age");
        breedField = addField(content, "Breed");
        weightField = addField(content, "Weight");
        temperamentField = addMultilineField(content, "Temperament and handling notes");
        doNotDoField = addMultilineField(content, "Do not do");
        feedingField = addMultilineField(content, "Feeding instructions");
        waterField = addField(content, "Water instructions");
        walksField = addMultilineField(content, "Walk frequency");
        foodsToAvoidField = addMultilineField(content, "Foods or situations to avoid");
        medicationNameField = addField(content, "Medication name");
        medicationDoseField = addField(content, "Medication dose");
        medicationTimeField = addField(content, "Medication time, for example 08:00,20:00");
        missedDoseField = addMultilineField(content, "Missed-dose instruction");
        ownerPhoneField = addField(content, "Owner phone");
        clinicPhoneField = addField(content, "Clinic phone");
        caregiverField = addField(content, "Caregiver name");
        caregiverTypeField = addField(content, "Caregiver type");
        tripNoteField = addMultilineField(content, "Trip or boarding note");

        Button sampleButton = new Button(this);
        sampleButton.setText("Load sample data");
        sampleButton.setOnClickListener(view -> loadSampleData());
        content.addView(sampleButton);

        Button saveButton = new Button(this);
        saveButton.setText("Save draft");
        saveButton.setOnClickListener(view -> saveDraft());
        content.addView(saveButton);

        Button clearButton = new Button(this);
        clearButton.setText("Clear draft");
        clearButton.setOnClickListener(view -> clearDraft());
        content.addView(clearButton);

        Button buildButton = new Button(this);
        buildButton.setText("Build handoff card");
        buildButton.setOnClickListener(view -> buildCard());
        content.addView(buildButton);

        shareButton = new Button(this);
        shareButton.setText("Share plain text");
        shareButton.setEnabled(false);
        shareButton.setOnClickListener(view -> sharePlainText());
        content.addView(shareButton);

        readinessOutput = new TextView(this);
        readinessOutput.setTextSize(16);
        readinessOutput.setPadding(0, 24, 0, 16);
        content.addView(readinessOutput);

        cardOutput = new TextView(this);
        cardOutput.setTextSize(14);
        cardOutput.setTextColor(Color.rgb(45, 45, 45));
        content.addView(cardOutput);

        restoreDraft();
        setContentView(scrollView);
    }

    private EditText addField(LinearLayout parent, String hint) {
        EditText field = new EditText(this);
        field.setHint(hint);
        field.setSingleLine(true);
        parent.addView(field);
        return field;
    }

    private EditText addMultilineField(LinearLayout parent, String hint) {
        EditText field = new EditText(this);
        field.setHint(hint);
        field.setSingleLine(false);
        field.setMinLines(2);
        field.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE);
        parent.addView(field);
        return field;
    }

    private void loadSampleData() {
        dogNameField.setText("Lucky");
        ageField.setText("13 years");
        breedField.setText("Corgi");
        weightField.setText("12.5kg");
        temperamentField.setText("Friendly but anxious around stairs and loud dryers.");
        doNotDoField.setText("Do not give table scraps. Do not allow jumping from sofas.");
        feedingField.setText("Two meals, 80g each. No chicken bones.");
        waterField.setText("Refresh water every morning and evening.");
        walksField.setText("Short walk after breakfast, dinner, and before bed.");
        foodsToAvoidField.setText("Avoid chicken bones, grapes, raisins, onions, and salty snacks.");
        medicationNameField.setText("Pimobendan");
        medicationDoseField.setText("1 tablet");
        medicationTimeField.setText("08:00,20:00");
        missedDoseField.setText("Call the owner before making up a missed dose.");
        ownerPhoneField.setText("TEST-OWNER-PHONE");
        clinicPhoneField.setText("TEST-CLINIC-PHONE");
        caregiverField.setText("Boarding staff");
        caregiverTypeField.setText("Boarding");
        tripNoteField.setText("Owner is away for one night. Call before changing food or medication.");
        buildCard();
    }

    private void saveDraft() {
        SharedPreferences.Editor editor = getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit();
        put(editor, "dogName", dogNameField);
        put(editor, "age", ageField);
        put(editor, "breed", breedField);
        put(editor, "weight", weightField);
        put(editor, "temperament", temperamentField);
        put(editor, "doNotDo", doNotDoField);
        put(editor, "feeding", feedingField);
        put(editor, "water", waterField);
        put(editor, "walks", walksField);
        put(editor, "foodsToAvoid", foodsToAvoidField);
        put(editor, "medicationName", medicationNameField);
        put(editor, "medicationDose", medicationDoseField);
        put(editor, "medicationTime", medicationTimeField);
        put(editor, "missedDose", missedDoseField);
        put(editor, "ownerPhone", ownerPhoneField);
        put(editor, "clinicPhone", clinicPhoneField);
        put(editor, "caregiver", caregiverField);
        put(editor, "caregiverType", caregiverTypeField);
        put(editor, "tripNote", tripNoteField);
        editor.apply();
        buildCard();
    }

    private void restoreDraft() {
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        if (!prefs.contains("dogName")) {
            return;
        }

        read(prefs, "dogName", dogNameField);
        read(prefs, "age", ageField);
        read(prefs, "breed", breedField);
        read(prefs, "weight", weightField);
        read(prefs, "temperament", temperamentField);
        read(prefs, "doNotDo", doNotDoField);
        read(prefs, "feeding", feedingField);
        read(prefs, "water", waterField);
        read(prefs, "walks", walksField);
        read(prefs, "foodsToAvoid", foodsToAvoidField);
        read(prefs, "medicationName", medicationNameField);
        read(prefs, "medicationDose", medicationDoseField);
        read(prefs, "medicationTime", medicationTimeField);
        read(prefs, "missedDose", missedDoseField);
        read(prefs, "ownerPhone", ownerPhoneField);
        read(prefs, "clinicPhone", clinicPhoneField);
        read(prefs, "caregiver", caregiverField);
        read(prefs, "caregiverType", caregiverTypeField);
        read(prefs, "tripNote", tripNoteField);
        buildCard();
    }

    private void clearDraft() {
        getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().clear().apply();
        dogNameField.setText("");
        ageField.setText("");
        breedField.setText("");
        weightField.setText("");
        temperamentField.setText("");
        doNotDoField.setText("");
        feedingField.setText("");
        waterField.setText("");
        walksField.setText("");
        foodsToAvoidField.setText("");
        medicationNameField.setText("");
        medicationDoseField.setText("");
        medicationTimeField.setText("");
        missedDoseField.setText("");
        ownerPhoneField.setText("");
        clinicPhoneField.setText("");
        caregiverField.setText("");
        caregiverTypeField.setText("");
        tripNoteField.setText("");
        buildCard();
    }

    private void buildCard() {
        DogProfile profile = readProfile();
        HandoffDraft draft = new HandoffDraft();
        draft.caregiverName = text(caregiverField);
        draft.caregiverType = text(caregiverTypeField);
        draft.tripNote = text(tripNoteField);

        HandoffReadinessReport report = HandoffReadiness.evaluate(profile, draft);
        HandoffCardSnapshot snapshot = HandoffCardBuilder.build(profile, draft);
        latestPlainText = snapshot.plainText;

        readinessOutput.setText(formatReadiness(report));
        cardOutput.setText(snapshot.plainText);
        shareButton.setEnabled(!report.hasBlockers());
    }

    private DogProfile readProfile() {
        DogProfile profile = new DogProfile();
        profile.name = text(dogNameField);
        profile.age = text(ageField);
        profile.breed = text(breedField);
        profile.weight = text(weightField);
        profile.temperament = text(temperamentField);
        profile.doNotDo = text(doNotDoField);
        profile.careRule.feeding = text(feedingField);
        profile.careRule.water = text(waterField);
        profile.careRule.walks = text(walksField);
        profile.careRule.foodsToAvoid = text(foodsToAvoidField);
        profile.careRule.callOwnerIf = "Call owner if medication is refused, appetite changes, vomiting starts, or behavior changes sharply.";
        profile.careRule.goVetIf = "Go to a vet for breathing trouble, seizures, collapse, poisoning risk, bleeding, or ongoing vomiting.";

        if (!HandoffReadiness.isBlank(text(medicationNameField))
            || !HandoffReadiness.isBlank(text(medicationDoseField))
            || !HandoffReadiness.isBlank(text(medicationTimeField))) {
            MedicationItem medication = new MedicationItem();
            medication.name = text(medicationNameField);
            medication.dosage = text(medicationDoseField);
            medication.schedule = text(medicationTimeField);
            medication.missedDoseRule = text(missedDoseField);
            medication.withFood = "Follow owner instruction";
            profile.medications.add(medication);
        }

        EmergencyContact owner = new EmergencyContact();
        owner.role = "Owner";
        owner.name = "Owner";
        owner.phone = text(ownerPhoneField);
        profile.contacts.add(owner);

        EmergencyContact clinic = new EmergencyContact();
        clinic.role = "Clinic";
        clinic.name = "Clinic";
        clinic.phone = text(clinicPhoneField);
        profile.contacts.add(clinic);

        return profile;
    }

    private String formatReadiness(HandoffReadinessReport report) {
        StringBuilder builder = new StringBuilder();
        builder.append("Readiness: ").append(report.score).append(" / 100\n");
        builder.append(report.statusTitle()).append("\n");
        builder.append(report.statusDescription()).append("\n");

        for (HandoffReadinessItem item : report.priorityItems()) {
            builder
                .append("\n- ")
                .append(item.title)
                .append(": ")
                .append(item.detail);
        }
        return builder.toString();
    }

    private void sharePlainText() {
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TEXT, latestPlainText);
        startActivity(Intent.createChooser(intent, "Share handoff card"));
    }

    private String text(EditText field) {
        return field.getText().toString().trim();
    }

    private void put(SharedPreferences.Editor editor, String key, EditText field) {
        editor.putString(key, text(field));
    }

    private void read(SharedPreferences prefs, String key, EditText field) {
        field.setText(prefs.getString(key, ""));
    }
}
