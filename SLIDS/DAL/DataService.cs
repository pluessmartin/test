using System;
using System.Linq;
using System.Linq.Expressions;


namespace Pentag.SLIDS.DAL
{
    public class DataService<TObject> where TObject : class
    {

        protected Entities _data;

        public DataService(Entities data)
        {
            _data = data;
        }

        public IQueryable<TObject> GetAll()
        {
            return _data.Set<TObject>();
        }

        public TObject Get(int id)
        {
            return _data.Set<TObject>().Find(id);
        }

        public TObject Find(Expression<Func<TObject, bool>> match)
        {
            return _data.Set<TObject>().SingleOrDefault(match);
        }

        public IQueryable<TObject> FindAll(Expression<Func<TObject, bool>> match)
        {
            return _data.Set<TObject>().Where(match);
        }

        public TObject Add(TObject t)
        {
            _data.Set<TObject>().Add(t);
            _data.SaveChanges();
            return t;
        }

        public TObject Update(TObject updated, int key)
        {
            if (updated == null)
                return null;

            TObject existing = _data.Set<TObject>().Find(key);
            if (existing != null)
            {
                _data.Entry(existing).CurrentValues.SetValues(updated);
                _data.SaveChanges();
            }
            return existing;
        }

        public void Delete(TObject t)
        {
            _data.Set<TObject>().Remove(t);
            _data.SaveChanges();
        }

        public int Count()
        {
            return _data.Set<TObject>().Count();
        }
    }
}