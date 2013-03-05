---
title: Template for SQLAlchemy Declarative
author: Donald Curtis
tags: sqlalchemy
---

Below are Python files to get started using [SQLAlchemy](http://www.sqlalchemy.org/) in a project. 


The `db.py` file contains,

    from sqlalchemy import Column, Boolean, BigInteger, DateTime, ForeignKey, Integer, Numeric, String, Table, Text
    from sqlalchemy.ext.declarative import declarative_base, declared_attr
    from sqlalchemy.orm import relationship, backref, deferred
    from sqlalchemy.ext.associationproxy import association_proxy
    
    engine = None
    sessionmaker = sa.orm.sessionmaker()
    session = sa.orm.scoped_session(sessionmaker)
    
    def configure_engine(url):
        global sessionmaker, engine, session
    
        engine = sa.create_engine(url)
        session.remove()
        sessionmaker.configure(bind=engine)
    
    _config = Config('')
    configure_engine(os.environ.get("DATABASE_URL", "postgres://localhost/defaultdb"))
    
    class _Base(object):
        @declared_attr
        def __tablename__(cls):
            """
            Convert CamelCase class name to underscores_between_words
            table name.
            """
    
            name = cls.__name__
            return (
                name[0].lower() +
                re.sub(r'([A-Z])', lambda m:"_" + m.group(0).lower(), name[1:])
            )
    
    
    Base = declarative_base(cls=_Base)
    Base.query = session.query_property()


One should adjust the imports accordingly and setup the configuration settings so that `configure_engine` pulls from the appropriate location. In this example we only look at the `DATABASE_URL` environment variable and default to localhost using the `defaultdb` database.

You can then create new models like,

    class Account(Base):
        id = Column(Integer, primary_key=True)
        created = Column(DateTime, default=sa.sql.func.now())
        username = Column(String(128))
        active = Column(Boolean, default=True)
        admin = Column(Boolean, default=False)
        image_url = Column(String)
    
        def __init__(self, username=None):
            """
    
            Arguments:
            - `self`:
            - `username`:
            """
            if username is not None: self.username = username


I then also include a script called `create_db.py` that simply contains,

    import db
    
    db.Base.metadata.drop_all(db.engine)
    db.Base.metadata.create_all(db.engine)


    # comment the following lines if not using alembic
    from alembic.config import Config
    from alembic import command
    alembic_cfg = Config("alembic.ini")
    command.stamp(alembic_cfg, "head")


Note that the second part of this file contains instructions for [Alembic](http://alembic.readthedocs.org/en/latest/) which I use for migrations.
