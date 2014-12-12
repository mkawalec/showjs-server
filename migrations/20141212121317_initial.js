'use strict';

function addId(knex, t) {
  t.uuid('id').defaultTo(knex.raw('uuid_generate_v4()')).index().primary();
}

exports.up = function(knex, Promise) {
  return new Promise(function(res) {
    return knex.raw('CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public')
      .then(function() {
      return knex.schema.createTable('presentations', function(t) {
        addId(knex, t);
        t.timestamp('created_at').defaultTo(knex.raw('now()')).notNull();

        t.string('password').notNull();
        t.string('salt').notNull();
        t.text('address');

        t.string('type').notNull().default('ShowJS').index();
      });
    }).then(function() {
      return knex.schema.createTable('steps', function(t) {
        addId(knex, t);
        t.timestamp('created_at').defaultTo(knex.raw('now()')).index().notNull();

        t.specificType('payload', 'json');
        t.uuid('presentation_id').references('presentations.id').index().notNull();
      });
    }).then(function() {
      return knex.schema.createTable('notes', function(t) {
        addId(knex, t);
        t.timestamp('created_at').defaultTo(knex.raw('now()')).notNull();
        t.timestamp('updated_at').defaultTo(knex.raw('now()')).notNull();

        t.uuid('reply_to').references('notes.id').index();
        t.uuid('presentation_id').references('presentations.id').index().notNull();

        t.text('note');
        t.specificType('position', 'json');
      });
    }).then(res);
  });
};

exports.down = function(knex, Promise) {
  
};
